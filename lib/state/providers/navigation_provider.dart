import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/game_config.dart';
import '../../config/combat_config.dart';
import '../../combat/auto_combat_resolver.dart';
import '../../combat/build_resolver.dart';
import '../../combat/zone_node_roller.dart';
import '../../db/db_service.dart';
import 'player_provider.dart';
import 'inventory_provider.dart';
import 'combat_settings_provider.dart';
import 'legacy_activity_provider.dart';

class _StepYield {
  int nothingCount = 0;
  int combatWins = 0;
  int combatLosses = 0;
  int combatFlees = 0;
  int goldEarned = 0;
  int totalSteps = 0;
  final Map<String, int> gatheredDrops = {};
  final Map<String, int> treasureDrops = {};
  final Map<String, int> combatDrops = {};
  final List<String> travelLogs = []; // New field

  void addGather(String itemName, int qty) {
    gatheredDrops[itemName] = (gatheredDrops[itemName] ?? 0) + qty;
  }
  void addTreasure(String itemName, int qty) {
    treasureDrops[itemName] = (treasureDrops[itemName] ?? 0) + qty;
  }
  void addCombat(String itemName, int qty) {
    combatDrops[itemName] = (combatDrops[itemName] ?? 0) + qty;
  }

  String buildMessage() {
    List<String> parts = [];
    if (travelLogs.isNotEmpty) { // Added travelLogs to message
      parts.add(travelLogs.join('\n'));
    }
    if (gatheredDrops.isNotEmpty) {
      final drops = gatheredDrops.entries.map((e) => '${e.value}x ${e.key}').join(', ');
      parts.add('⛏ Gathered: $drops');
    }
    if (treasureDrops.isNotEmpty) {
      final drops = treasureDrops.entries.map((e) => '${e.value}x ${e.key}').join(', ');
      parts.add('💰 Treasure: $drops');
    }
    if (combatWins > 0 || combatDrops.isNotEmpty || goldEarned > 0) {
      String dropsStr = '';
      if (combatDrops.isNotEmpty) {
        dropsStr = ', ${combatDrops.entries.map((e) => '${e.value}x ${e.key}').join(', ')}';
      }
      parts.add('⚔ Won $combatWins fights (+${goldEarned}g$dropsStr)');
    }
    if (combatFlees > 0) parts.add('🏃 Fled $combatFlees times');
    if (combatLosses > 0) parts.add('💀 Defeated $combatLosses times');
    if (nothingCount > 0) parts.add('🌿 $nothingCount quiet moments');

    return parts.join('\n');
  }
}

class NavigationState {
  final String currentLocationId;
  final ActiveNode? currentNode;
  final String? travelDestinationId;
  final int travelStepsRemaining;
  final String? lastNodeMessage;
  final CombatResult? lastCombatResult;
  final List<String> enabledGatherIds;
  final bool combatEnabled;

  const NavigationState({
    required this.currentLocationId,
    required this.currentNode,
    required this.travelDestinationId,
    required this.travelStepsRemaining,
    required this.lastNodeMessage,
    required this.lastCombatResult,
    required this.enabledGatherIds,
    required this.combatEnabled,
  });

  NavigationState copyWith({
    String? currentLocationId,
    ActiveNode? currentNode,
    bool clearNode = false, // Use clearNode to explicitly set currentNode to null
    String? travelDestinationId,
    bool clearDestination = false,
    int? travelStepsRemaining,
    String? lastNodeMessage,
    bool clearMessage = false,
    CombatResult? lastCombatResult,
    bool clearCombatResult = false,
    List<String>? enabledGatherIds,
    bool? combatEnabled,
  }) {
    return NavigationState(
      currentLocationId: currentLocationId ?? this.currentLocationId,
      currentNode: clearNode ? null : (currentNode ?? this.currentNode),
      travelDestinationId: clearDestination ? null : (travelDestinationId ?? this.travelDestinationId),
      travelStepsRemaining: travelStepsRemaining ?? this.travelStepsRemaining,
      lastNodeMessage: clearMessage ? null : (lastNodeMessage ?? this.lastNodeMessage),
      lastCombatResult: clearCombatResult ? null : (lastCombatResult ?? this.lastCombatResult),
      enabledGatherIds: enabledGatherIds ?? this.enabledGatherIds,
      combatEnabled: combatEnabled ?? this.combatEnabled,
    );
  }

  LocationEntity? get currentLocation => GameConfig.location(currentLocationId);
  String get locationLabel => currentLocation?.name ?? currentLocationId;
  bool get isTraveling => travelDestinationId != null && travelStepsRemaining > 0;
  bool get isInSafeLocation => currentLocation?.isTeleportHub ?? false;
}

class NavigationNotifier extends Notifier<NavigationState> {
  final Random _rng = Random();

  @override
  NavigationState build() {
    final cur = DbService.save;
    
    ActiveNode? activeNode;
    if (cur.currentNodeJson != null && cur.currentNodeJson!.isNotEmpty) {
      try {
        activeNode = ActiveNode.fromJson(jsonDecode(cur.currentNodeJson!));
      } catch (_) {}
    }

    // Schedule rolling the next node if it's null on boot
    if (activeNode == null) {
      Future.microtask(() => _rollNextNode());
    }

    return NavigationState(
      currentLocationId: cur.currentLocationId.isEmpty ? 'millhaven_fields' : cur.currentLocationId,
      currentNode: activeNode,
      travelDestinationId: cur.travelDestinationId,
      travelStepsRemaining: cur.travelStepsRemaining,
      lastNodeMessage: null,
      lastCombatResult: null,
      enabledGatherIds: List<String>.from(cur.enabledGatherIds),
      combatEnabled: cur.combatEnabled,
    );
  }

  Future<void> _save() async {
    await DbService.updateSave((s) {
      s.currentLocationId = state.currentLocationId;
      s.travelDestinationId = state.travelDestinationId;
      s.travelStepsRemaining = state.travelStepsRemaining;
      s.currentNodeJson = state.currentNode != null ? jsonEncode(state.currentNode!.toJson()) : null;
      s.enabledGatherIds = state.enabledGatherIds;
      s.combatEnabled = state.combatEnabled;
    });
  }

  Future<void> applySteps(int steps) async {
    if (steps <= 0) return;
    
    await ref.read(playerProvider.notifier).addSteps(steps);
    
    final legacyMsgs = ref.read(legacyActivityProvider.notifier).applySteps(steps);

    int stepsRemaining = steps;
    final yieldObj = _StepYield();

    // 1) Process Travel Path
    while (state.isTraveling && stepsRemaining > 0) {
      if (stepsRemaining >= state.travelStepsRemaining) {
        stepsRemaining -= state.travelStepsRemaining;
        yieldObj.totalSteps += state.travelStepsRemaining;
        
        // Segment finished
        final dest = state.travelDestinationId!;
        final currentNext = _getNextZoneId(state.currentLocationId, dest);
        
        if (currentNext == dest) {
          // Final arrival
          state = state.copyWith(
            currentLocationId: dest,
            clearDestination: true,
            travelStepsRemaining: 0,
            clearNode: true,
          );
          yieldObj.travelLogs.add('🗺 Arrived at ${GameConfig.location(dest)?.name ?? dest}');
          _rollNextNode();
        } else {
          // Path into next intermediate zone
          final newNextZone = _getNextZoneId(currentNext, dest);
          final travelCost = GameConfig.location(newNextZone)?.travelSteps ?? 200;
          
          state = state.copyWith(
            currentLocationId: currentNext,
            travelStepsRemaining: travelCost,
            clearNode: true,
          );
          yieldObj.travelLogs.add('🗺 Passed through ${GameConfig.location(currentNext)?.name ?? currentNext}...');
          _rollNextNode();
        }
      } else {
        // En route
        state = state.copyWith(travelStepsRemaining: state.travelStepsRemaining - stepsRemaining);
        yieldObj.totalSteps += stepsRemaining;
        stepsRemaining = 0;
      }
    }

    // 2) Process Area Nodes (using any leftover steps, or all steps if not traveling)
    while (stepsRemaining > 0) {
      final node = state.currentNode;
      if (node == null) break;

      int stepsNeeded = node.stepsRequired - node.stepsProgress;
      if (stepsRemaining >= stepsNeeded) {
        // Complete the node
        stepsRemaining -= stepsNeeded;
        yieldObj.totalSteps += stepsNeeded;
        node.stepsProgress = node.stepsRequired;
        _processNode(node, yieldObj);
        _rollNextNode();
      } else {
        // Partial progress
        node.stepsProgress += stepsRemaining;
        state = state.copyWith(currentNode: node);
        yieldObj.totalSteps += stepsRemaining;
        stepsRemaining = 0;
      }
    }

    final accumulatorMsg = yieldObj.buildMessage();
    if (legacyMsgs.isNotEmpty || accumulatorMsg.trim().isNotEmpty) {
      final allMsgs = [...legacyMsgs, if (accumulatorMsg.trim().isNotEmpty) accumulatorMsg].join('\n\n');
      state = state.copyWith(lastNodeMessage: allMsgs);
    }
    await _save();
  }

  void _processNode(ActiveNode node, _StepYield yieldObj) {
    switch (node.type) {
      case NodeType.gather:   _processGather(node, yieldObj); break;
      case NodeType.combat:   _processCombat(node, yieldObj); break;
      case NodeType.treasure: _processTreasure(node, yieldObj); break;
      case NodeType.nothing:  yieldObj.nothingCount++; break;
    }
  }

  void _processGather(ActiveNode node, _StepYield yieldObj) {
    final actId = node.activityId;
    final activity = actId != null ? GameConfig.activity(actId) : null;
    if (activity == null) return;

    final invNotifier = ref.read(inventoryProvider.notifier);
    
    // Gather nodes do not use a loot_table in this engine iteration, they output a direct item
    final outId = activity.outputItemId;
    final outQty = (activity.raw['output_quantity'] as num? ?? 1).toInt();

    invNotifier.upsertInventoryItem(outId, outQty);
    final itemName = GameConfig.item(outId)?.name ?? outId;
    yieldObj.addGather(itemName, outQty);
  }

  void _processCombat(ActiveNode node, _StepYield yieldObj) {
    final monster = node.monsterId != null ? GameConfig.monster(node.monsterId!) : null;
    if (monster == null) return;

    final gearSlots = ref.read(inventoryProvider).gearSlots;
    final combatSettings = ref.read(combatSettingsProvider);
    
    final result = AutoCombatResolver.resolve(
      monster: monster,
      player: BuildResolver.resolve(gearSlots),
      settings: combatSettings,
      rng: _rng,
    );
    
    state = state.copyWith(lastCombatResult: result);

    switch (result) {
      case VictoryResult r:
        yieldObj.combatWins++;
        yieldObj.goldEarned += r.goldEarned;
        ref.read(playerProvider.notifier).updateGold(r.goldEarned);
        
        final invNotifier = ref.read(inventoryProvider.notifier);
        for (final drop in r.loot) {
          invNotifier.upsertInventoryItem(drop.itemId, drop.quantity);
          final itemName = GameConfig.item(drop.itemId)?.name ?? drop.itemId;
          yieldObj.addCombat(itemName, drop.quantity);
        }
        break;

      case FleeResult _:
        yieldObj.combatFlees++;
        break;

      case DefeatResult _:
        yieldObj.combatLosses++;
        final hub = state.currentLocation?.nearestHub ?? 'ironhaven';
        final stepBank = ref.read(playerProvider).stepBank;
        final penalty = (stepBank * 0.10).round();
        ref.read(playerProvider.notifier).updateStepBank((stepBank - penalty).clamp(0, stepBank));
        
        state = state.copyWith(
          currentLocationId: hub,
          clearNode: true,
          clearDestination: true,
          travelStepsRemaining: 0,
        );
        break;
    }
  }

  void _processTreasure(ActiveNode node, _StepYield yieldObj) {
    final invNotifier = ref.read(inventoryProvider.notifier);
    
    for (final entry in node.lootTable) {
      if (_rng.nextDouble() < entry.chance) {
        final qty = entry.rollQuantity(_rng);
        invNotifier.upsertInventoryItem(entry.itemId, qty);
        final itemName = GameConfig.item(entry.itemId)?.name ?? entry.itemId;
        yieldObj.addTreasure(itemName, qty);
      }
    }
  }

  void _rollNextNode() {
    final config = GameConfig.zoneNodes(state.currentLocationId);
    if (config == null) {
      state = state.copyWith(clearNode: true);
      return;
    }
    
    // Only roll activities that the player has toggled ON, and are valid for this location
    final availableGatherActIds = GameConfig
        .gatherActivitiesForLocation(state.currentLocationId)
        .map((a) => a.id)
        .toList();
    
    final allowedGatherIds = availableGatherActIds.where((id) => state.enabledGatherIds.contains(id)).toList();
    
    // If no gathering selected, and potentially no combat, ZoneNodeRoller will naturally favor treasure/nothing
    final nextNode = ZoneNodeRoller.roll(
      config, 
      _rng, 
      gatherActivityIds: allowedGatherIds,
      combatEnabled: state.combatEnabled,
    );
    
    state = state.copyWith(currentNode: nextNode);
    // Note: Do not _save() here as it is called heavily in the while loop.
    // The while loop (_applySteps) will call _save() exactly once at the end.
  }

  void toggleGatherFilter(String activityId) {
    final next = List<String>.from(state.enabledGatherIds);
    if (next.contains(activityId)) {
      next.remove(activityId);
    } else {
      next.add(activityId);
    }
    state = state.copyWith(enabledGatherIds: next);
    _save();
  }

  void toggleCombat(bool enabled) {
    state = state.copyWith(combatEnabled: enabled);
    _save();
  }

  void travelTo(String locationId) {
    if (state.currentLocationId == locationId) return;
    
    state = state.copyWith(
      currentLocationId: locationId,
      clearNode: true,
    );
    _rollNextNode();
  }

  void setDestination(String locationId, List<String> activityIds) {
    if (state.currentLocationId == locationId) return;
    
    // Begin pathing to the first adjacent zone
    final firstStepId = _getNextZoneId(state.currentLocationId, locationId);
    final loc = GameConfig.location(firstStepId);
    if (loc == null) return;

    state = state.copyWith(
      travelDestinationId: locationId,
      travelStepsRemaining: loc.travelSteps,
      enabledGatherIds: activityIds.isNotEmpty ? activityIds : state.enabledGatherIds,
      clearNode: true,
    );
    _save();
  }

  int calculatePathSteps(String destId) {
    if (state.currentLocationId == destId) return 0;
    
    int total = 0;
    String curr = state.currentLocationId;
    while (curr != destId) {
      curr = _getNextZoneId(curr, destId);
      total += GameConfig.location(curr)?.travelSteps ?? 200;
    }
    return total;
  }

  void teleportToHub(String hubId) {
    state = state.copyWith(
      currentLocationId: hubId,
      clearDestination: true,
      travelStepsRemaining: 0,
      clearNode: true,
    );
    _rollNextNode();
  }

  void clearCombatResult() {
    state = state.copyWith(clearCombatResult: true);
  }

  // ── Pathfinding Helper ──────────────────────────────────────────

  String _getNextZoneId(String current, String dest) {
    Point<int>? getCoord(String id) {
      if (id == 'ironhaven') return const Point(2, 2);
      if (id == 'ashgrove') return const Point(8, 2);
      if (id == 'tanners_rest') return const Point(2, 8);
      if (id == 'silkwatch') return const Point(8, 8);
      if (id == 'crimson_citadel') return const Point(5, 5);
      if (id.startsWith('beginner_town_')) {
        final p = id.split('_'); return Point(int.parse(p[2]), int.parse(p[3]));
      }
      if (id.startsWith('zone_')) {
        final p = id.split('_'); return Point(int.parse(p[1]), int.parse(p[2]));
      }
      return null;
    }
    
    final c = getCoord(current);
    final d = getCoord(dest);
    if (c == null || d == null) return dest;
    
    int dx = (d.x - c.x).sign;
    int dy = (d.y - c.y).sign;
    int nx = c.x + dx;
    int ny = c.y + dy;
    
    if (nx == d.x && ny == d.y) return dest;
    
    if (nx == 5 && ny == 5) return 'crimson_citadel';
    if (nx == 2 && ny == 2) return 'ironhaven';
    if (nx == 8 && ny == 2) return 'ashgrove';
    if (nx == 2 && ny == 8) return 'tanners_rest';
    if (nx == 8 && ny == 8) return 'silkwatch';
    if ((nx==0&&ny==0) || (nx==10&&ny==0) || (nx==0&&ny==10) || (nx==10&&ny==10)) {
      return 'beginner_town_${nx}_$ny';
    }
    return 'zone_${nx}_$ny';
  }
}

final navigationProvider = NotifierProvider<NavigationNotifier, NavigationState>(() {
  return NavigationNotifier();
});
