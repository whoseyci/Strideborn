import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../db/db_service.dart';
import '../../config/game_config.dart';
import 'inventory_provider.dart';

class LegacyActivityState {
  final Set<String> activeActivityIds;
  final String? walkToCraftActivityId;
  final int walkProgress;

  const LegacyActivityState({
    required this.activeActivityIds,
    required this.walkToCraftActivityId,
    required this.walkProgress,
  });

  LegacyActivityState copyWith({
    Set<String>? activeActivityIds,
    String? walkToCraftActivityId,
    int? walkProgress,
  }) {
    return LegacyActivityState(
      activeActivityIds: activeActivityIds ?? this.activeActivityIds,
      walkToCraftActivityId: walkToCraftActivityId ?? this.walkToCraftActivityId,
      walkProgress: walkProgress ?? this.walkProgress,
    );
  }
}

class LegacyActivityNotifier extends Notifier<LegacyActivityState> {
  @override
  LegacyActivityState build() {
    final cur = DbService.save;
    return LegacyActivityState(
      activeActivityIds: cur.activeActivityIds.toSet(),
      walkToCraftActivityId: cur.walkToCraftActivityId,
      walkProgress: cur.walkProgress,
    );
  }

  Future<void> _save() async {
    await DbService.updateSave((s) {
      s.activeActivityIds = state.activeActivityIds.toList();
      s.walkToCraftActivityId = state.walkToCraftActivityId;
      s.walkProgress = state.walkProgress;
    });
  }

  void toggleActivity(String activityId) {
    final next = Set<String>.from(state.activeActivityIds);
    if (next.contains(activityId)) {
      next.remove(activityId);
    } else {
      next.add(activityId);
    }
    state = state.copyWith(activeActivityIds: next);
    _save();
  }

  void startWalkToCraft(String activityId) {
    state = state.copyWith(walkToCraftActivityId: activityId, walkProgress: 0);
    _save();
  }

  void cancelWalkToCraft() {
    state = LegacyActivityState(
      activeActivityIds: state.activeActivityIds,
      walkToCraftActivityId: null,
      walkProgress: 0,
    );
    _save();
  }

  List<String> applySteps(int steps) {
    if (state.walkToCraftActivityId == null) return [];
    final act = GameConfig.activity(state.walkToCraftActivityId!);
    if (act == null) return [];

    int newProgress = state.walkProgress + steps;
    int completions = 0;

    final currentInv = Map<String, int>.from(ref.read(inventoryProvider).inventory);

    while (newProgress >= act.stepsPerNode) {
      bool matsOk = true;
      for (final e in act.inputItems.entries) {
        if ((currentInv[e.key] ?? 0) < e.value) { matsOk = false; break; }
      }
      if (!matsOk) break;

      completions++;
      newProgress -= act.stepsPerNode;
      for (final e in act.inputItems.entries) {
        currentInv[e.key] = (currentInv[e.key] ?? 0) - e.value;
      }
      currentInv[act.outputItemId] = (currentInv[act.outputItemId] ?? 0) + 1;
    }

    if (completions > 0) {
      final invNotifier = ref.read(inventoryProvider.notifier);
      for (int i = 0; i < completions; i++) {
        for (final e in act.inputItems.entries) {
          invNotifier.upsertInventoryItem(e.key, -e.value);
        }
        invNotifier.upsertInventoryItem(act.outputItemId, 1);
      }
      
      bool matsOk = true;
      final freshInv = ref.read(inventoryProvider).inventory;
      for (final e in act.inputItems.entries) {
        if ((freshInv[e.key] ?? 0) < e.value) { matsOk = false; break; }
      }
      
      final outName = GameConfig.item(act.outputItemId)?.name ?? act.outputItemId;
      final msg = '✓ Crafted $completions× $outName';
      
      if (!matsOk) {
        state = LegacyActivityState(
          activeActivityIds: state.activeActivityIds,
          walkToCraftActivityId: null,
          walkProgress: 0,
        );
        _save();
        return [msg, '❌ Out of materials for $outName'];
      }
      
      state = state.copyWith(walkProgress: newProgress);
      _save();
      return [msg];
    }
    
    state = state.copyWith(walkProgress: newProgress);
    _save();
    return [];
  }
}

final legacyActivityProvider = NotifierProvider<LegacyActivityNotifier, LegacyActivityState>(() {
  return LegacyActivityNotifier();
});
