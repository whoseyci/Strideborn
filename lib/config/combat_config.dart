import 'dart:math';

// ════════════════════════════════════════════════════════
// COMBAT CONFIG
// All data types for the combat & zone-node system.
// Every entry lives in JSON. No hardcoded content here.
// ════════════════════════════════════════════════════════

// ── Effect types ─────────────────────────────────────────────────
// Adding a new effect = one new value here + one case in EffectResolver.tick()
enum EffectType {
  // Damage over time
  bleed, burn, poison, corruption,
  // Heal over time
  regen,
  // Armor modifiers
  armorBreak, armorBuff,
  // Attack modifiers
  attackBuff, attackDebuff,
  // Speed modifiers
  speedBuff, speedDebuff,
  // Crowd control
  stun, freeze, silence,
  // ADDED: slow (+1 to cooldowns while active), weaken (-20% damage dealt),
  //        blind (-30% accuracy on physical attacks for duration)
  slow, weaken, blind,
  // Special
  mark, exposed, barrier,
}

// ── Live effect instance (ECS component) ─────────────────────────
class CombatEffect {
  final String instanceId;
  final EffectType type;
  final double magnitude;
  int turnsRemaining;
  final bool stackable;
  final int maxStacks;
  int currentStacks;

  CombatEffect({
    required this.instanceId,
    required this.type,
    required this.magnitude,
    required int durationTurns,
    this.stackable = false,
    this.maxStacks = 1,
    this.currentStacks = 1,
  }) : turnsRemaining = durationTurns;
}

// ── Effect config (JSON template for a single effect application) ─
class EffectConfig {
  final EffectType type;
  final double magnitude;
  final int duration;
  final double chance;
  final bool stackable;
  final int maxStacks;

  const EffectConfig({
    required this.type,
    required this.magnitude,
    required this.duration,
    required this.chance,
    this.stackable = false,
    this.maxStacks = 1,
  });

  factory EffectConfig.fromJson(Map<String, dynamic> j) {
    final typeName = j['type'] as String;
    final type = EffectType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => throw ArgumentError('Unknown EffectType: $typeName'),
    );
    return EffectConfig(
      type: type,
      magnitude: (j['magnitude'] as num).toDouble(),
      duration: (j['duration'] as num).toInt(),
      chance: (j['chance'] as num).toDouble(),
      stackable: j['stackable'] as bool? ?? false,
      maxStacks: (j['max_stacks'] as num? ?? 1).toInt(),
    );
  }
}

// ── Ability target ────────────────────────────────────────────────
enum AbilityTarget { single, allEnemies, self, none }

// ── Ability entity ────────────────────────────────────────────────
// Shared by player gear AND monster ability lists. Referenced by ID everywhere.
// JSON key for cooldown: "cooldown_turns" (replaces legacy "stamina_cost")
class AbilityEntity {
  final String id;
  final String name;
  final String icon;
  final AbilityTarget target;
  final int hits;
  final double damageMult;
  // CHANGED: staminaCost removed; cooldownTurns = turns unavailable after use (0 = always available)
  final int cooldownTurns;
  final List<EffectConfig> effectsOnHit;
  final List<EffectConfig> effectsOnSelf;
  final bool isPassive;
  final String? trigger;        // 'combat_start' | 'on_hit_received'
  final double triggerChance;
  final double? executeThreshold; // instant kill if target HP% < this

  const AbilityEntity({
    required this.id,
    required this.name,
    required this.icon,
    this.target = AbilityTarget.single,
    this.hits = 1,
    this.damageMult = 1.0,
    this.cooldownTurns = 0,
    this.effectsOnHit = const [],
    this.effectsOnSelf = const [],
    this.isPassive = false,
    this.trigger,
    this.triggerChance = 1.0,
    this.executeThreshold,
  });

  factory AbilityEntity.fromJson(String id, Map<String, dynamic> j) {
    final targetStr = j['target'] as String? ?? 'single';
    final target = switch (targetStr) {
      'all_enemies' => AbilityTarget.allEnemies,
      'self'        => AbilityTarget.self,
      'none'        => AbilityTarget.none,
      _             => AbilityTarget.single,
    };

    List<EffectConfig> parseEffects(dynamic raw) => (raw as List? ?? [])
        .map((e) => EffectConfig.fromJson(e as Map<String, dynamic>))
        .toList();

    final onHit  = parseEffects(j['effects_on_hit'] ?? j['effects']);
    final onSelf = parseEffects(j['effects_on_self']);

    return AbilityEntity(
      id: id,
      name: j['name'] as String,
      icon: j['icon'] as String? ?? '⚔',
      target: target,
      hits: (j['hits'] as num? ?? 1).toInt(),
      damageMult: (j['damage_mult'] as num? ?? 1.0).toDouble(),
      // CHANGED: reads "cooldown_turns"; falls back to 0 if missing
      cooldownTurns: (j['cooldown_turns'] as num? ?? 0).toInt(),
      effectsOnHit: onHit,
      effectsOnSelf: onSelf,
      isPassive: j['is_passive'] as bool? ?? false,
      trigger: j['trigger'] as String?,
      triggerChance: (j['trigger_chance'] as num? ?? 1.0).toDouble(),
      executeThreshold: j['execute_threshold'] != null
          ? (j['execute_threshold'] as num).toDouble()
          : null,
    );
  }
}

// ── Loot entry ────────────────────────────────────────────────────
class LootEntry {
  final String itemId;
  final int quantityMin;
  final int quantityMax;
  final double chance;

  const LootEntry({
    required this.itemId,
    required this.quantityMin,
    required this.quantityMax,
    required this.chance,
  });

  factory LootEntry.fromJson(Map<String, dynamic> j) {
    final qty = j['quantity'];
    int qMin = 1, qMax = 1;
    if (qty is List) {
      qMin = (qty[0] as num).toInt();
      qMax = (qty[1] as num).toInt();
    } else if (qty is num) {
      qMin = qMax = qty.toInt();
    }
    return LootEntry(
      itemId: j['item_id'] as String,
      quantityMin: qMin,
      quantityMax: qMax,
      chance: (j['chance'] as num).toDouble(),
    );
  }

  int rollQuantity(Random rng) => quantityMin == quantityMax
      ? quantityMin
      : quantityMin + rng.nextInt(quantityMax - quantityMin + 1);
}

// ── Monster ability reference ─────────────────────────────────────
class MonsterAbilityRef {
  final String abilityId;
  final int weight;
  final String? condition; // 'hp_below_50' | 'hp_above_75' | null

  const MonsterAbilityRef({
    required this.abilityId,
    required this.weight,
    this.condition,
  });

  factory MonsterAbilityRef.fromJson(Map<String, dynamic> j) =>
      MonsterAbilityRef(
        abilityId: j['id'] as String,
        weight: (j['weight'] as num? ?? 50).toInt(),
        condition: j['condition'] as String?,
      );
}

// ── Monster phase (stat changes + ability overrides at HP thresholds) ─
class MonsterPhase {
  final double hpThreshold;
  final double attackMult;
  final double speedMult;
  final String? forceAbilityId;

  const MonsterPhase({
    required this.hpThreshold,
    this.attackMult = 1.0,
    this.speedMult = 1.0,
    this.forceAbilityId,
  });

  factory MonsterPhase.fromJson(Map<String, dynamic> j) {
    final stats = j['stat_modifier'] as Map<String, dynamic>? ?? {};
    return MonsterPhase(
      hpThreshold: (j['hp_threshold'] as num).toDouble(),
      attackMult: (stats['attack'] as num? ?? 1.0).toDouble(),
      speedMult: (stats['speed'] as num? ?? 1.0).toDouble(),
      forceAbilityId: j['force_ability'] as String?,
    );
  }
}

// ── Monster template ──────────────────────────────────────────────
class MonsterTemplate {
  final String id;
  final String name;
  final String icon;
  final int tier;
  final int hp;
  final int attack;
  // defense is stored as DR% integer (0–30), matching the player DR system
  final int defense;
  final int speed;
  final int stepsToResolve;
  final int goldMin;
  final int goldMax;
  final List<LootEntry> lootTable;
  final List<MonsterAbilityRef> abilityRefs;
  final List<MonsterPhase> phases;

  const MonsterTemplate({
    required this.id,
    required this.name,
    required this.icon,
    required this.tier,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.stepsToResolve,
    required this.goldMin,
    required this.goldMax,
    required this.lootTable,
    required this.abilityRefs,
    this.phases = const [],
  });

  factory MonsterTemplate.fromJson(Map<String, dynamic> j) {
    final gold = j['gold_reward'] as Map<String, dynamic>? ?? {};
    return MonsterTemplate(
      id: j['id'] as String,
      name: j['name'] as String,
      icon: j['icon'] as String? ?? '👾',
      tier: (j['tier'] as num? ?? 1).toInt(),
      hp: (j['hp'] as num).toInt(),
      attack: (j['attack'] as num).toInt(),
      defense: (j['defense'] as num? ?? 0).toInt(),
      speed: (j['speed'] as num? ?? 10).toInt(),
      stepsToResolve: (j['steps_to_resolve'] as num? ?? 150).toInt(),
      goldMin: (gold['min'] as num? ?? 0).toInt(),
      goldMax: (gold['max'] as num? ?? 0).toInt(),
      lootTable: (j['loot_table'] as List? ?? [])
          .map((e) => LootEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      abilityRefs: (j['abilities'] as List? ?? [])
          .map((e) => MonsterAbilityRef.fromJson(e as Map<String, dynamic>))
          .toList(),
      phases: (j['phases'] as List? ?? [])
          .map((e) => MonsterPhase.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── Zone node types ───────────────────────────────────────────────
enum NodeType { gather, combat, treasure, nothing }

// ── Node table entry (one row in a zone's weighted table) ─────────
class NodeTableEntry {
  final NodeType type;
  final int weight;
  final String? activityId;
  final List<String> monsterIds;
  final List<LootEntry> lootTable;
  final int? stepsOverride;

  const NodeTableEntry({
    required this.type,
    required this.weight,
    this.activityId,
    this.monsterIds = const [],
    this.lootTable = const [],
    this.stepsOverride,
  });

  factory NodeTableEntry.fromJson(Map<String, dynamic> j) {
    final typeStr = j['type'] as String? ?? 'nothing';
    final type = switch (typeStr) {
      'gather'   => NodeType.gather,
      'combat'   => NodeType.combat,
      'treasure' => NodeType.treasure,
      _          => NodeType.nothing,
    };
    return NodeTableEntry(
      type: type,
      weight: (j['weight'] as num).toInt(),
      activityId: j['activity_id'] as String?,
      monsterIds: List<String>.from(j['monster_ids'] ?? []),
      lootTable: (j['loot_table'] as List? ?? [])
          .map((e) => LootEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      stepsOverride: j['steps_override'] as int?,
    );
  }
}

// ── Zone node config (full table for one zone) ────────────────────
class ZoneNodeConfig {
  final String zoneId;
  final int stepsPerNodeBase;
  final List<NodeTableEntry> nodeTable;

  const ZoneNodeConfig({
    required this.zoneId,
    required this.stepsPerNodeBase,
    required this.nodeTable,
  });

  int get totalWeight => nodeTable.fold(0, (s, e) => s + e.weight);

  factory ZoneNodeConfig.fromJson(Map<String, dynamic> j) => ZoneNodeConfig(
        zoneId: j['zone_id'] as String,
        stepsPerNodeBase: (j['steps_per_node_base'] as num? ?? 100).toInt(),
        nodeTable: (j['node_table'] as List)
            .map((e) => NodeTableEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ── Active node (current node being worked on) ────────────────────
class ActiveNode {
  final NodeType type;
  final int stepsRequired;
  int stepsProgress;

  final String? activityId;
  final String? monsterId;
  final List<LootEntry> lootTable;

  ActiveNode({
    required this.type,
    required this.stepsRequired,
    this.stepsProgress = 0,
    this.activityId,
    this.monsterId,
    this.lootTable = const [],
  });

  double get progressFraction =>
      stepsRequired > 0 ? (stepsProgress / stepsRequired).clamp(0.0, 1.0) : 0.0;

  String get typeIcon => switch (type) {
        NodeType.gather   => '⛏',
        NodeType.combat   => '⚔',
        NodeType.treasure => '💰',
        NodeType.nothing  => '🌿',
      };

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'steps_required': stepsRequired,
        'steps_progress': stepsProgress,
        'activity_id': activityId,
        'monster_id': monsterId,
      };

  factory ActiveNode.fromJson(Map<String, dynamic> j) {
    final type = NodeType.values.firstWhere(
      (t) => t.name == (j['type'] as String? ?? 'nothing'),
      orElse: () => NodeType.nothing,
    );
    return ActiveNode(
      type: type,
      stepsRequired: (j['steps_required'] as num? ?? 100).toInt(),
      stepsProgress: (j['steps_progress'] as num? ?? 0).toInt(),
      activityId: j['activity_id'] as String?,
      monsterId: j['monster_id'] as String?,
    );
  }
}

// ── Combat settings (player preferences for auto-resolution) ─────
// CHANGED: removed staminaFloor and useStepBankForCombat (stamina system retired)
class CombatSettings {
  List<String> abilityPriority;  // ordered list of ability IDs to try first
  double fleeHpThreshold;        // flee if player HP% drops below (0 = never)

  CombatSettings({
    List<String>? abilityPriority,
    this.fleeHpThreshold = 0.0,
  }) : abilityPriority = abilityPriority ?? [];

  Map<String, dynamic> toJson() => {
        'ability_priority': abilityPriority,
        'flee_hp_threshold': fleeHpThreshold,
      };

  factory CombatSettings.fromJson(Map<String, dynamic> j) => CombatSettings(
        abilityPriority: List<String>.from(j['ability_priority'] ?? []),
        fleeHpThreshold: (j['flee_hp_threshold'] as num? ?? 0.0).toDouble(),
      );
}

// ── Player combat stats (assembled from gear by BuildResolver) ────
// CHANGED: maxStamina + staminaRegen replaced by passiveRegen (HP/turn, IP-derived)
class PlayerCombatStats {
  final int maxHp;
  final int attack;
  // defense = DR% stored as integer 0–30 (matches IP × 0.006 × 100, capped at 30)
  final int defense;
  final int speed;
  final int passiveRegen;   // HP healed at end of each combat round
  final List<AbilityEntity> activeAbilities;
  final List<AbilityEntity> passives;

  const PlayerCombatStats({
    required this.maxHp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.passiveRegen,
    required this.activeAbilities,
    required this.passives,
  });
}

// ── Combat results ────────────────────────────────────────────────
class LootDrop {
  final String itemId;
  final int quantity;
  const LootDrop(this.itemId, this.quantity);
}

enum CombatEventType { start, attack, execute, heal, effectTick, stun, status, flee, miss }

class CombatEvent {
  final CombatEventType type;
  final String actor;
  final String? target;
  final String message;
  final int? value;
  final String? abilityName;
  final String? effectIcon;

  const CombatEvent({
    required this.type,
    required this.actor,
    this.target,
    required this.message,
    this.value,
    this.abilityName,
    this.effectIcon,
  });
}

sealed class CombatResult {
  final List<CombatEvent> timeline;
  const CombatResult({required this.timeline});
}

class VictoryResult extends CombatResult {
  final List<LootDrop> loot;
  final int goldEarned;
  final int hpRemaining;
  final int rounds;

  const VictoryResult({
    required this.loot,
    required this.goldEarned,
    required this.hpRemaining,
    required this.rounds,
    required super.timeline,
  });
}

class DefeatResult extends CombatResult {
  final int roundsSurvived;
  const DefeatResult({
    required this.roundsSurvived,
    required super.timeline,
  });
}

class FleeResult extends CombatResult {
  const FleeResult({required super.timeline});
}