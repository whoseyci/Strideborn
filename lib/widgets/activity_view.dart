import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/combat_config.dart';
import '../config/game_config.dart';
import '../state/providers/navigation_provider.dart';

// ════════════════════════════════════════════════════════
// ACTIVITY VIEW
// Shows what the player is currently doing and progress
// toward completing the current zone node.
// ════════════════════════════════════════════════════════

class ActivityView extends ConsumerStatefulWidget {
  final Function(String)? onFeedback;
  const ActivityView({super.key, this.onFeedback});

  @override
  ConsumerState<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends ConsumerState<ActivityView> {
  final _stepsController = TextEditingController();

  @override
  void dispose() {
    _stepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(navigationProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Status bar ───────────────────────────────────────
        _NodeStatusBar(navState: navState),

        // ── Last message ─────────────────────────────────────
        if (navState.lastNodeMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              navState.lastNodeMessage!,
              style: const TextStyle(color: Colors.amber, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),

            // ── Step input ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _stepsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter steps',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final n = int.tryParse(_stepsController.text);
                    if (n != null && n > 0) {
                      ref.read(navigationProvider.notifier).applySteps(n);
                      _stepsController.clear();
                    }
                  },
                  child: const Text('Log'),
                ),
              ]),
            ),
          ],
        );
  }
}

// ── Node status bar ────────────────────────────────────────────────

class _NodeStatusBar extends StatelessWidget {
  final NavigationState navState;
  const _NodeStatusBar({required this.navState});

  @override
  Widget build(BuildContext context) {
    if (navState.isTraveling) {
      final dest = GameConfig.location(navState.travelDestinationId!)?.name ?? navState.travelDestinationId!;
      final current = GameConfig.location(navState.currentLocationId)?.name ?? navState.currentLocationId;
      final travelSteps = GameConfig.location(navState.currentLocationId)?.travelSteps ?? 200;
      final traveled = travelSteps - navState.travelStepsRemaining;
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('🗺', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Expanded(
              child: Text('Walking to $dest',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis),
            ),
            Text(
              '$traveled / $travelSteps',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.only(left: 22, top: 2),
            child: Text('Passing through $current',
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: traveled / travelSteps,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Colors.blue),
              minHeight: 4,
            ),
          ),
        ]),
      );
    }

    final n = navState.currentNode;
    if (n == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text('Ready to explore…',
            style: TextStyle(color: Colors.white54, fontSize: 13)),
      );
    }

    final label  = _nodeLabel(n);
    final detail = _nodeDetail(n);
    final progress = n.progressFraction;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Icon + label + step count
        Row(children: [
          Text(n.typeIcon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
          ),
          Text(
            '${n.stepsProgress} / ${n.stepsRequired}',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ]),
        if (detail != null)
          Padding(
            padding: const EdgeInsets.only(left: 22, top: 2),
            child: Text(detail,
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ),
        const SizedBox(height: 4),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(_barColor(n.type)),
            minHeight: 4,
          ),
        ),
      ]),
    );
  }

  String _nodeLabel(ActiveNode n) {
    switch (n.type) {
      case NodeType.gather:
        final act = n.activityId != null ? GameConfig.activity(n.activityId!) : null;
        return act?.name ?? 'Gathering';
      case NodeType.combat:
        final monster = n.monsterId != null ? GameConfig.monster(n.monsterId!) : null;
        return monster != null
            ? '${monster.icon} Encounter: ${monster.name}'
            : 'Combat Encounter';
      case NodeType.treasure:
        return 'Hidden Treasure';
      case NodeType.nothing:
        return 'Exploring…';
    }
  }

  String? _nodeDetail(ActiveNode n) {
    switch (n.type) {
      case NodeType.combat:
        final monster = n.monsterId != null ? GameConfig.monster(n.monsterId!) : null;
        if (monster == null) return null;
        return 'T${monster.tier} · ${monster.hp} HP · ${monster.attack} ATK';
      default:
        return null;
    }
  }

  Color _barColor(NodeType type) => switch (type) {
        NodeType.gather   => Colors.green,
        NodeType.combat   => Colors.red,
        NodeType.treasure => Colors.amber,
        NodeType.nothing  => Colors.blueGrey,
      };
}