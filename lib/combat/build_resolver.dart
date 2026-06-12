import '../config/combat_config.dart';
import '../config/game_config.dart';

// ════════════════════════════════════════════════════════
// BUILD RESOLVER
// Walks the player's equipped gear slots and assembles
// a PlayerCombatStats snapshot for use in AutoCombatResolver.
//
// CHANGED: stats are now derived from total IP (GDD §4.2).
//   maxHp      = totalIP × 2.5
//   attack     = totalIP × 0.8
//   defense    = totalIP × 0.006 × 100, capped at 30 (DR%)
//   passiveRegen = totalIP × 0.05
//   speed      = base + gear additions (not in IP formula)
//
// Stamina system removed — replaced by per-ability cooldowns.
// ════════════════════════════════════════════════════════

class BuildResolver {
  // Speed is the only stat still accumulated from gear directly.
  // All HP/attack/defense/regen derive from IP.
  static const int _baseSpeed = 10;

  static PlayerCombatStats resolve(Map<String, String?> gearSlots) {
    var totalIp = 0;
    var speed   = _baseSpeed;

    final activeAbilities = <AbilityEntity>[];
    final passives        = <AbilityEntity>[];
    final seenAbilityIds  = <String>{};

    for (final itemId in gearSlots.values.whereType<String>()) {
      final item = GameConfig.item(itemId);
      if (item == null) continue;

      // Each equipped item contributes its IP (tier × 100 by default)
      totalIp += item.baseIp;

      // Speed is the one stat still read directly from item.stats
      speed += (item.stats['speed'] as num? ?? 0).toInt();

      // Pull abilities from item — each item has:
      //   abilities: { active: [...ids], passive: [...ids] }
      final itemAbilities = item.abilities;
      if (itemAbilities != null) {
        for (final id in (itemAbilities['active'] ?? [])) {
          if (seenAbilityIds.add(id)) {
            final ab = GameConfig.ability(id);
            if (ab != null && !ab.isPassive) activeAbilities.add(ab);
          }
        }
        for (final id in (itemAbilities['passive'] ?? [])) {
          if (seenAbilityIds.add(id)) {
            final ab = GameConfig.ability(id);
            if (ab != null && ab.isPassive) passives.add(ab);
          }
        }
      }
    }

    // Derive stats from total IP (GDD §4.2)
    // Minimum values prevent completely broken combat with zero gear equipped
    final maxHp      = (totalIp * 2.5).round().clamp(50, 99999);
    final attack     = (totalIp * 0.8).round().clamp(5, 99999);
    // defense stored as integer DR% 0–30 (matches effectiveDefense clamp)
    final defense    = (totalIp * 0.006 * 100).round().clamp(0, 30);
    final passiveRegen = (totalIp * 0.05).round().clamp(0, 99999);

    return PlayerCombatStats(
      maxHp: maxHp,
      attack: attack,
      defense: defense,
      speed: speed.clamp(0, 99999),
      passiveRegen: passiveRegen,
      activeAbilities: activeAbilities,
      passives: passives,
    );
  }
}