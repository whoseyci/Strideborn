import 'dart:math';
import '../config/combat_config.dart';

// ════════════════════════════════════════════════════════
// ZONE NODE ROLLER
// After each completed node, call roll() to get the next one.
// All weighting is in zone_nodes.json — no code changes needed
// to rebalance encounter frequency.
// ════════════════════════════════════════════════════════

class ZoneNodeRoller {
  /// Roll the next node from a zone's table.
  /// Returns an ActiveNode ready to be set as GameState.currentNode.
  static ActiveNode roll(
    ZoneNodeConfig zone,
    Random rng, {
    /// Zone's available gather activity IDs (used when table entry has no activityId).
    List<String> gatherActivityIds = const [],
    bool combatEnabled = true,
  }) {
    final table = zone.nodeTable;
    if (table.isEmpty) return _nothingNode(zone.stepsPerNodeBase);

    final validEntries = <NodeTableEntry, int>{};
    int totalWeight = 0;

    for (final entry in table) {
      if (!combatEnabled && entry.type == NodeType.combat) continue;

      if (entry.type == NodeType.gather) {
        if (entry.activityId != null && !gatherActivityIds.contains(entry.activityId)) {
          continue;
        }
        if (entry.activityId == null && gatherActivityIds.isEmpty) {
          continue;
        }
      }

      int weight = entry.weight;
      if (!combatEnabled && entry.type == NodeType.treasure) {
        // Penalty to treasure drops if safe mode
        weight = (weight * 0.25).round().clamp(1, weight); 
      }

      validEntries[entry] = weight;
      totalWeight += weight;
    }

    if (validEntries.isEmpty) return _nothingNode(zone.stepsPerNodeBase);

    int cursor = rng.nextInt(totalWeight);
    NodeTableEntry? picked;

    for (final e in validEntries.entries) {
      cursor -= e.value;
      if (cursor <= 0) {
        picked = e.key;
        break;
      }
    }
    picked ??= validEntries.keys.last;

    return _buildNode(picked, zone.stepsPerNodeBase, gatherActivityIds, rng);
  }

  static ActiveNode _buildNode(
    NodeTableEntry entry,
    int baseSteps,
    List<String> gatherActivityIds,
    Random rng,
  ) {
    final steps = entry.stepsOverride ?? baseSteps;

    switch (entry.type) {
      case NodeType.gather:
        // If the table specifies an activityId, use it.
        // Otherwise pick randomly from the zone's gather activities.
        String? actId = entry.activityId;
        if (actId == null && gatherActivityIds.isNotEmpty) {
          actId = gatherActivityIds[rng.nextInt(gatherActivityIds.length)];
        }
        return ActiveNode(
          type: NodeType.gather,
          stepsRequired: steps,
          activityId: actId,
        );

      case NodeType.combat:
        if (entry.monsterIds.isEmpty) {
          return _nothingNode(steps);
        }
        final monsterId =
            entry.monsterIds[rng.nextInt(entry.monsterIds.length)];
        return ActiveNode(
          type: NodeType.combat,
          stepsRequired: steps,
          monsterId: monsterId,
        );

      case NodeType.treasure:
        // Treasure resolves immediately — stepsRequired is effectively 0
        // but we still show a brief "searching..." progress for UX.
        return ActiveNode(
          type: NodeType.treasure,
          stepsRequired: (steps * 0.25).round().clamp(10, steps),
          lootTable: entry.lootTable,
        );

      case NodeType.nothing:
        return _nothingNode(steps);
    }
  }

  static ActiveNode _nothingNode(int steps) => ActiveNode(
        type: NodeType.nothing,
        stepsRequired: (steps * 0.50).round().clamp(10, steps),
      );
}
