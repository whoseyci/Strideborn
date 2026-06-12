import 'dart:math';
import '../config/combat_config.dart';

// ════════════════════════════════════════════════════════
// EFFECT RESOLVER
// Pure static functions — no state.
// Every status effect interaction lives here.
// To add a new EffectType: add one case in tick().
// ════════════════════════════════════════════════════════

class EffectResolver {
  static int _idCounter = 0;
  static String _nextId() => 'e${_idCounter++}';

  // ── Apply ─────────────────────────────────────────────
  /// Applies an EffectConfig to a live effect list.
  /// Respects stackability and max-stacks rules.
  static void apply(
    EffectConfig cfg,
    List<CombatEffect> effects,
    Random rng,
  ) {
    if (rng.nextDouble() >= cfg.chance) return;

    if (cfg.stackable) {
      final existing = effects.where((e) => e.type == cfg.type).toList();
      if (existing.isNotEmpty) {
        final top = existing.first;
        if (top.currentStacks < cfg.maxStacks) {
          top.currentStacks++;
          top.turnsRemaining = cfg.duration; // refresh on new stack
        }
        return;
      }
    } else {
      effects.removeWhere((e) => e.type == cfg.type);
    }

    effects.add(CombatEffect(
      instanceId: _nextId(),
      type: cfg.type,
      magnitude: cfg.magnitude,
      durationTurns: cfg.duration,
      stackable: cfg.stackable,
      maxStacks: cfg.maxStacks,
    ));
  }

  // ── Tick ──────────────────────────────────────────────
  /// Call at the START of each round, before any attacks.
  /// Ticks DoT/HoT, decrements durations, removes expired effects.
  static ({int hp, List<CombatEvent> events}) tick({
    required List<CombatEffect> effects,
    required int currentHp,
    required int maxHp,
    required int defense,
    required String name,
  }) {
    int hp = currentHp;
    final events = <CombatEvent>[];
    final expired = <String>[];

    for (final e in effects) {
      switch (e.type) {
        case EffectType.bleed:
          final dmg = _dotDmg(e, defense, mitigFactor: 0.30);
          hp = (hp - dmg).clamp(0, maxHp);
          events.add(CombatEvent(type: CombatEventType.effectTick, actor: name, target: name, message: '💉 $name bleeds — $dmg dmg', value: dmg, effectIcon: '💉'));

        case EffectType.burn:
          final dmg = _dotDmg(e, defense, mitigFactor: 0.15);
          hp = (hp - dmg).clamp(0, maxHp);
          events.add(CombatEvent(type: CombatEventType.effectTick, actor: name, target: name, message: '🔥 $name burns — $dmg dmg', value: dmg, effectIcon: '🔥'));

        case EffectType.poison:
          final dmg = _dotDmg(e, defense, mitigFactor: 0.20);
          hp = (hp - dmg).clamp(0, maxHp);
          events.add(CombatEvent(type: CombatEventType.effectTick, actor: name, target: name, message: '☠ $name poisoned — $dmg dmg', value: dmg, effectIcon: '☠'));

        case EffectType.corruption:
          // Bypasses armor entirely
          final dmg = (e.magnitude * e.currentStacks).round().clamp(1, 99999);
          hp = (hp - dmg).clamp(0, maxHp);
          events.add(CombatEvent(type: CombatEventType.effectTick, actor: name, target: name, message: '💀 $name corrupts — $dmg dmg (ignores armor)', value: dmg, effectIcon: '💀'));

        case EffectType.regen:
          final heal = (e.magnitude * e.currentStacks).round();
          hp = (hp + heal).clamp(0, maxHp);
          events.add(CombatEvent(type: CombatEventType.heal, actor: name, target: name, message: '💚 $name regenerates $heal HP', value: heal, effectIcon: '💚'));

        // ADDED: slow, weaken, blind — no tick damage; they expire by duration only.
        // Their combat impact is checked via the helper queries below.
        case EffectType.slow:
        case EffectType.weaken:
        case EffectType.blind:
          break;

        default:
          break; // Stat modifiers don't tick — they modify getters on read
      }

      e.turnsRemaining--;
      if (e.turnsRemaining <= 0) expired.add(e.instanceId);
    }

    effects.removeWhere((e) => expired.contains(e.instanceId));
    return (hp: hp, events: events);
  }

  // ── Stat queries ──────────────────────────────────────

  static int effectiveAttack(int base, List<CombatEffect> effects) {
    double v = base.toDouble();
    for (final e in effects) {
      if (e.type == EffectType.attackBuff)   v *= (1 + e.magnitude * e.currentStacks);
      if (e.type == EffectType.attackDebuff) v *= (1 - e.magnitude * e.currentStacks);
      // ADDED: weaken reduces damage dealt by 20% (no stacking per GDD §8.6)
      if (e.type == EffectType.weaken)       v *= 0.80;
    }
    return v.round().clamp(1, 99999);
  }

  /// Returns effective DR% as integer 0–30.
  static int effectiveDefense(int base, List<CombatEffect> effects) {
    double v = base.toDouble();
    for (final e in effects) {
      if (e.type == EffectType.armorBuff)  v *= (1 + e.magnitude * e.currentStacks);
      if (e.type == EffectType.armorBreak) v *= (1 - e.magnitude * e.currentStacks);
    }
    // CHANGED: clamp to 30 — defense is DR% with a hard 30% cap (GDD §4.2)
    return v.round().clamp(0, 30);
  }

  static bool isStunned(List<CombatEffect> effects) =>
      effects.any((e) => e.type == EffectType.stun || e.type == EffectType.freeze);

  static bool isSilenced(List<CombatEffect> effects) =>
      effects.any((e) => e.type == EffectType.silence);

  // ADDED: helpers for new CC effects

  /// True while a slow effect is active — caller adds +1 to ability cooldown when set.
  static bool isSlowed(List<CombatEffect> effects) =>
      effects.any((e) => e.type == EffectType.slow);

  /// 30% miss chance on physical attacks while blinded.
  static bool isBlinded(List<CombatEffect> effects) =>
      effects.any((e) => e.type == EffectType.blind);

  // ── Helpers ───────────────────────────────────────────

  /// CHANGED: defense is now DR% (0–30). mitigFactor scales how much of the
  /// DR applies to this DoT type (bleeds are harder to resist than burns, etc).
  static int _dotDmg(CombatEffect e, int defense, {required double mitigFactor}) {
    final mitigation = (defense / 100.0 * mitigFactor).clamp(0.0, 0.60);
    return (e.magnitude * e.currentStacks * (1 - mitigation))
        .round()
        .clamp(1, 99999);
  }
}