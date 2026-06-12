import 'dart:math';
import '../config/combat_config.dart';
import '../config/game_config.dart';
import 'effect_resolver.dart';

// ════════════════════════════════════════════════════════
// AUTO COMBAT RESOLVER
// Pure function — takes stats + settings + rng, returns result.
// No UI, no async, no side effects.
// Called by GameState._processNode() when a combat node completes.
//
// CHANGED: stamina system replaced with per-ability cooldowns.
// Round structure: DoTs tick → player turn → monster turn →
//                 passive regen → cooldowns decrement.
// ════════════════════════════════════════════════════════

class AutoCombatResolver {
  static CombatResult resolve({
    required MonsterTemplate monster,
    required PlayerCombatStats player,
    required CombatSettings settings,
    required Random rng,
  }) {
    // ── Mutable combat state ───────────────────────────────
    var playerHp   = player.maxHp;
    var monsterHp  = monster.hp;
    final playerFx  = <CombatEffect>[];
    final monsterFx = <CombatEffect>[];
    final timeline  = <CombatEvent>[];
    var round       = 0;

    // CHANGED: cooldown maps replace stamina tracking.
    // key = ability ID, value = turns remaining on cooldown (0 = available)
    final playerCooldowns  = <String, int>{};
    final monsterCooldowns = <String, int>{};

    // ── Combat-start passives ──────────────────────────────
    for (final passive in player.passives) {
      if (passive.trigger == 'combat_start') {
        for (final cfg in passive.effectsOnSelf) {
          EffectResolver.apply(cfg, playerFx, rng);
        }
      }
    }

    // Higher speed goes first
    final playerFirst = player.speed >= monster.speed;

    // ── Main loop (cap 50 rounds to prevent infinite HoT standoffs) ─
    while (playerHp > 0 && monsterHp > 0 && round < 50) {
      round++;

      // 1. Tick DoTs / HoTs at round START (before any attacks)
      final pt = EffectResolver.tick(
        effects: playerFx, currentHp: playerHp,
        maxHp: player.maxHp, defense: player.defense, name: 'You',
      );
      playerHp = pt.hp;
      timeline.addAll(pt.events);
      if (playerHp <= 0) break;

      final mt = EffectResolver.tick(
        effects: monsterFx, currentHp: monsterHp,
        maxHp: monster.hp, defense: monster.defense, name: monster.name,
      );
      monsterHp = mt.hp;
      timeline.addAll(mt.events);
      if (monsterHp <= 0) break;

      // Lowest HP threshold that is satisfied = active phase
      final hpPct = monsterHp / monster.hp;
      MonsterPhase? phase;
      for (final p in monster.phases) {
        if (hpPct <= p.hpThreshold) phase = p;
      }

      // 2. Two turns per round, order set at combat start
      for (final isPlayer in (playerFirst ? [true, false] : [false, true])) {
        if (playerHp <= 0 || monsterHp <= 0) break;

        if (isPlayer) {
          // ── Flee check ───────────────────────────────────
          if (settings.fleeHpThreshold > 0 &&
              playerHp / player.maxHp < settings.fleeHpThreshold) {
            timeline.add(const CombatEvent(type: CombatEventType.flee, actor: 'You', message: '🏃 Flee threshold reached. You escape!'));
            return FleeResult(timeline: timeline);
          }

          if (EffectResolver.isStunned(playerFx)) {
            timeline.add(const CombatEvent(type: CombatEventType.stun, actor: 'You', message: '⚡ You are stunned — turn skipped'));
          } else {
            final ability = _pickPlayerAbility(
                player.activeAbilities, playerCooldowns, settings, playerFx);

            if (ability.target == AbilityTarget.self) {
              for (final cfg in ability.effectsOnSelf) {
                EffectResolver.apply(cfg, playerFx, rng);
              }
              timeline.add(CombatEvent(type: CombatEventType.attack, actor: 'You', message: '✨ You use ${ability.name}', abilityName: ability.name));
            } else {
              final atk = EffectResolver.effectiveAttack(player.attack, playerFx);
              final def = EffectResolver.effectiveDefense(monster.defense, monsterFx);
              var totalDmg = 0;
              var executed = false;
              var missed   = false;

              for (int h = 0; h < ability.hits; h++) {
                // Execute threshold: instakill below HP%
                if (ability.executeThreshold != null &&
                    monsterHp / monster.hp < ability.executeThreshold!) {
                  timeline.add(CombatEvent(type: CombatEventType.execute, actor: 'You', target: monster.name, message: '💥 ${ability.name} EXECUTES ${monster.name}!', abilityName: ability.name));
                  monsterHp = 0;
                  executed = true;
                  break;
                }
                // ADDED: blind miss check (30% chance per physical hit)
                if (EffectResolver.isBlinded(playerFx) && rng.nextDouble() < 0.30) {
                  missed = true;
                  continue; // this hit misses, try next hit
                }
                totalDmg += _calcDmg(atk, ability.damageMult, def, rng);
              }

              if (missed && totalDmg == 0 && !executed) {
                timeline.add(CombatEvent(type: CombatEventType.miss, actor: 'You', target: monster.name, message: '💨 ${ability.name}: MISS!', abilityName: ability.name));
              } else if (!executed) {
                monsterHp = (monsterHp - totalDmg).clamp(0, monster.hp);
                timeline.add(CombatEvent(type: CombatEventType.attack, actor: 'You', target: monster.name, message: '⚔ ${ability.name}: $totalDmg dmg → ${monster.name} ($monsterHp HP)', value: totalDmg, abilityName: ability.name));
                if (monsterHp > 0) {
                  for (final cfg in ability.effectsOnHit) {
                    EffectResolver.apply(cfg, monsterFx, rng);
                  }
                }
              }
              for (final cfg in ability.effectsOnSelf) {
                EffectResolver.apply(cfg, playerFx, rng);
              }
            }

            // CHANGED: set cooldown after use (0 = basic attack, always free)
            if (ability.id != '__basic__' && ability.cooldownTurns > 0) {
              // ADDED: slow adds +1 to cooldown while active
              final cd = ability.cooldownTurns + (EffectResolver.isSlowed(playerFx) ? 1 : 0);
              playerCooldowns[ability.id] = cd;
            }
          }

        } else {
          // ── Monster turn ──────────────────────────────────
          if (EffectResolver.isStunned(monsterFx)) {
            timeline.add(CombatEvent(type: CombatEventType.stun, actor: monster.name, message: '🔒 ${monster.name} is stunned — turn skipped'));
          } else {
            final ref = _pickMonsterAbility(
                monster.abilityRefs, monsterHp, monster.hp, phase, monsterCooldowns, rng);

            // Resolve ability: phase-forced refs use '__basic__' fallback when needed
            final ability = ref.abilityId == '__basic__'
                ? _kBasicAttack
                : GameConfig.ability(ref.abilityId);

            if (ability != null) {
              final phaseAtkMult = phase?.attackMult ?? 1.0;
              final monsterBaseAtk = (monster.attack * phaseAtkMult).round();
              final monsterAtk =
                  EffectResolver.effectiveAttack(monsterBaseAtk, monsterFx);

              if (ability.target == AbilityTarget.self) {
                for (final cfg in ability.effectsOnSelf) {
                  EffectResolver.apply(cfg, monsterFx, rng);
                }
                timeline.add(CombatEvent(type: CombatEventType.attack, actor: monster.name, message: '🔮 ${monster.name}: ${ability.name}', abilityName: ability.name));
              } else {
                final def = EffectResolver.effectiveDefense(player.defense, playerFx);
                var totalDmg = 0;
                for (int h = 0; h < ability.hits; h++) {
                  // Blind applies to monster attacks too if blinded
                  if (EffectResolver.isBlinded(monsterFx) && rng.nextDouble() < 0.30) {
                    continue;
                  }
                  totalDmg += _calcDmg(monsterAtk, ability.damageMult, def, rng);
                }
                playerHp = (playerHp - totalDmg).clamp(0, player.maxHp);
                timeline.add(CombatEvent(type: CombatEventType.attack, actor: monster.name, target: 'You', message: '💢 ${monster.name} ${ability.name}: $totalDmg → you ($playerHp HP)', value: totalDmg, abilityName: ability.name));

                for (final cfg in ability.effectsOnHit) {
                  EffectResolver.apply(cfg, playerFx, rng);
                }
                for (final passive in player.passives) {
                  if (passive.trigger == 'on_hit_received' &&
                      rng.nextDouble() < passive.triggerChance) {
                    for (final cfg in passive.effectsOnHit) {
                      EffectResolver.apply(cfg, monsterFx, rng);
                    }
                    timeline.add(CombatEvent(type: CombatEventType.status, actor: 'You', message: '🛡 ${passive.name} triggers!'));
                  }
                }
              }

              // CHANGED: set monster ability cooldown
              if (ability.id != '__basic__' && ability.cooldownTurns > 0) {
                final cd = ability.cooldownTurns + (EffectResolver.isSlowed(monsterFx) ? 1 : 0);
                monsterCooldowns[ref.abilityId] = cd;
              }
            }
          }
        }
      }

      // 3. End of round: passive regen
      if (player.passiveRegen > 0 && playerHp > 0) {
        playerHp = (playerHp + player.passiveRegen).clamp(0, player.maxHp);
        timeline.add(CombatEvent(
          type: CombatEventType.heal,
          actor: 'You',
          message: '💚 You regenerate ${player.passiveRegen} HP ($playerHp HP)',
          value: player.passiveRegen,
        ));
      }

      // 4. End of round: decrement all cooldowns, remove zeroed entries
      playerCooldowns.updateAll((k, v) => v - 1);
      playerCooldowns.removeWhere((k, v) => v <= 0);
      monsterCooldowns.updateAll((k, v) => v - 1);
      monsterCooldowns.removeWhere((k, v) => v <= 0);
    }

    // ── Result ─────────────────────────────────────────────
    if (monsterHp <= 0) {
      final gold = monster.goldMin >= monster.goldMax
          ? monster.goldMin
          : monster.goldMin + rng.nextInt(monster.goldMax - monster.goldMin + 1);
      return VictoryResult(
        loot: _rollLoot(monster.lootTable, rng),
        goldEarned: gold,
        hpRemaining: playerHp,
        rounds: round,
        timeline: timeline,
      );
    }
    return DefeatResult(roundsSurvived: round, timeline: timeline);
  }

  // ── Helpers ────────────────────────────────────────────────────

  /// CHANGED: defense is now DR% (0–30).
  /// damage = (attack × mult) ± 10% variance, reduced by DR%.
  static int _calcDmg(int attack, double mult, int defense, Random rng) {
    final base     = (attack * mult).round().clamp(1, 99999);
    final variance = (base * 0.10).round();
    final raw = variance > 0
        ? base + rng.nextInt(variance * 2 + 1) - variance
        : base;
    final dr = (defense / 100.0).clamp(0.0, 0.30);
    return (raw * (1 - dr)).round().clamp(1, 99999);
  }

  /// CHANGED: checks cooldowns instead of stamina.
  /// Priority list first → highest damageMult off cooldown → basic fallback.
  static AbilityEntity _pickPlayerAbility(
    List<AbilityEntity> abilities,
    Map<String, int> cooldowns,
    CombatSettings settings,
    List<CombatEffect> effects,
  ) {
    if (!EffectResolver.isSilenced(effects)) {
      // Try priority list first
      for (final id in settings.abilityPriority) {
        final ab = abilities.where((a) => a.id == id).firstOrNull;
        if (ab != null && (cooldowns[ab.id] ?? 0) == 0) {
          return ab;
        }
      }
      // Fallback: highest damageMult ability that is off cooldown
      final available = abilities
          .where((a) => (cooldowns[a.id] ?? 0) == 0)
          .toList()
        ..sort((a, b) => b.damageMult.compareTo(a.damageMult));
      if (available.isNotEmpty) return available.first;
    }
    return _kBasicAttack;
  }

  /// CHANGED: respects ability cooldowns. Phase force still overrides condition
  /// filters but now also respects the cooldown — if forced ability is on cooldown
  /// it falls through to normal weighted selection.
  static MonsterAbilityRef _pickMonsterAbility(
    List<MonsterAbilityRef> refs,
    int currentHp,
    int maxHp,
    MonsterPhase? phase,
    Map<String, int> cooldowns,
    Random rng,
  ) {
    // Phase force — only if off cooldown
    if (phase?.forceAbilityId != null) {
      final forced = refs.where((r) =>
          r.abilityId == phase!.forceAbilityId! &&
          (cooldowns[r.abilityId] ?? 0) == 0).firstOrNull;
      if (forced != null) return forced;
    }

    final hpPct = currentHp / maxHp;
    final available = refs.where((r) {
      if ((cooldowns[r.abilityId] ?? 0) > 0) return false; // on cooldown
      if (r.condition == 'hp_below_50') return hpPct < 0.50;
      if (r.condition == 'hp_above_75') return hpPct > 0.75;
      return true;
    }).toList();

    // All abilities on cooldown → fall back to basic attack
    if (available.isEmpty) return _kMonsterBasicRef;

    final total = available.fold(0, (s, r) => s + r.weight);
    int cursor = rng.nextInt(total);
    for (final ref in available) {
      cursor -= ref.weight;
      if (cursor <= 0) return ref;
    }
    return available.last;
  }

  static List<LootDrop> _rollLoot(List<LootEntry> table, Random rng) => table
      .where((e) => rng.nextDouble() < e.chance)
      .map((e) => LootDrop(e.itemId, e.rollQuantity(rng)))
      .toList();

  // CHANGED: cooldownTurns: 0 replaces staminaCost: 0
  static const _kBasicAttack = AbilityEntity(
    id: '__basic__',
    name: 'Attack',
    icon: '👊',
    target: AbilityTarget.single,
    hits: 1,
    damageMult: 1.0,
    cooldownTurns: 0,
  );

  // ADDED: returned by _pickMonsterAbility when all abilities are on cooldown
  static const _kMonsterBasicRef = MonsterAbilityRef(
    abilityId: '__basic__',
    weight: 1,
  );
}