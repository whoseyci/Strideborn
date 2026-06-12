import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/providers/navigation_provider.dart';
import '../../config/game_config.dart';
import '../world_map.dart';

// ═══════════════════════════════════════════════════════
// Map Overlay
//
// Compact centered popup.
// Top: square schematic map.
// Below: inline info panel when a node is selected.
//   • Hub  → city info (you are here / visit for Travel Agent)
//   • Zone → activity selector + travel button
// Teleport is available inside the city via the Travel Agent
// station in the zone view, not here.
// ═══════════════════════════════════════════════════════

class MapOverlay extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final Function(String) onFeedback;
  const MapOverlay({super.key, required this.onClose, required this.onFeedback});

  @override
  ConsumerState<MapOverlay> createState() => _MapOverlayState();
}

class _MapOverlayState extends ConsumerState<MapOverlay> {
  LocationEntity? _selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final screenW = MediaQuery.of(context).size.width;
    final popupW  = (screenW * 0.92).clamp(0.0, 420.0);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: popupW,
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.2), width: 0.75),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 8, 8),
              child: Row(children: [
                Text('WORLD MAP', style: TextStyle(
                  color: scheme.primary, fontSize: 12,
                  fontWeight: FontWeight.w900, letterSpacing: 2.5)),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: scheme.onSurface.withValues(alpha: 0.4), size: 18),
                  onPressed: widget.onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ]),
            ),

            // ── Square map ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: WorldMapWidget(
                    onLocationTap: (loc) => setState(() => _selected = loc),
                  ),
                ),
              ),
            ),

            // ── Info panel ─────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _selected == null
                  ? const SizedBox(key: ValueKey('empty'), height: 0)
                  : _selected!.isTeleportHub
                      ? _CityInfoPanel(
                          key: ValueKey(_selected!.id),
                          location: _selected!,
                          onClose: () => setState(() => _selected = null),
                          onGo: () {
                            ref.read(navigationProvider.notifier).setDestination(_selected!.id, []);
                            widget.onFeedback('Heading to ${_selected!.name}. Log steps to travel.');
                            widget.onClose();
                          },
                        )
                      : _ZoneInfoPanel(
                          key: ValueKey(_selected!.id),
                          location: _selected!,
                          onClose: () => setState(() => _selected = null),
                          onGo: (activityIds) {
                            ref.read(navigationProvider.notifier).setDestination(_selected!.id, activityIds);
                            widget.onFeedback('Heading to ${_selected!.name}. Log steps to travel.');
                            widget.onClose();
                          },
                        ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── City info panel ───────────────────────────────────────
class _CityInfoPanel extends ConsumerWidget {
  final LocationEntity location;
  final VoidCallback onClose;
  final VoidCallback onGo;
  const _CityInfoPanel({super.key, required this.location, required this.onClose, required this.onGo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final navState = ref.watch(navigationProvider);
    final isHere = navState.currentLocationId == location.id && !navState.isTraveling;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.18)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(location.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(child: Text(location.name,
              style: TextStyle(color: scheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold))),
          if (isHere)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('HERE', style: TextStyle(color: scheme.primary, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClose,
            child: Icon(Icons.close, size: 16, color: scheme.onSurface.withValues(alpha: 0.3)),
          ),
        ]),
        const SizedBox(height: 8),
        Text('City · Safe Zone',
            style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.45), fontSize: 11)),
        const SizedBox(height: 6),
        Text(
          isHere
              ? 'Visit the Travel Agent inside the city to teleport to other hubs.'
              : 'Travel here to access crafting stations and the Travel Agent.',
          style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.35), fontSize: 11),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isHere ? null : onGo,
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: Colors.black,
              disabledBackgroundColor: scheme.primary.withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            ),
            child: Text(
              isHere ? 'Already Here' : 'Travel to ${location.name} (${ref.read(navigationProvider.notifier).calculatePathSteps(location.id)} steps)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Zone info panel ───────────────────────────────────────
class _ZoneInfoPanel extends StatefulWidget {
  final LocationEntity location;
  final VoidCallback onClose;
  final Function(List<String>) onGo;
  const _ZoneInfoPanel({super.key, required this.location, required this.onClose, required this.onGo});

  @override
  State<_ZoneInfoPanel> createState() => _ZoneInfoPanelState();
}

class _ZoneInfoPanelState extends State<_ZoneInfoPanel> {
  final Set<String> _selected = {};

  Color _dangerColor(String d) {
    switch (d) {
      case 'safe': return const Color(0xFF1D9E75);
      case 'borderlands': return const Color(0xFFEF9F27);
      case 'cursed': return const Color(0xFFE24B4A);
      default: return const Color(0xFF534AB7);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme      = Theme.of(context).colorScheme;
    final activities  = GameConfig.gatheringAt(widget.location.id);
    final resources   = widget.location.resourceAvailability;
    final dangerColor = _dangerColor(widget.location.danger);
    final players     = playerCountFor(widget.location.id);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.18)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.location.name,
                style: TextStyle(color: scheme.onSurface, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 3),
            Row(children: [
              _Chip(label: 'T${widget.location.tier}', color: scheme.primary),
              const SizedBox(width: 5),
              _Chip(label: widget.location.danger, color: dangerColor),
              const SizedBox(width: 5),
              _Chip(label: '${widget.location.travelSteps} steps', color: scheme.onSurface.withValues(alpha: 0.4)),
            ]),
          ])),
          Column(children: [
            Text('$players', style: TextStyle(color: scheme.primary, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('online', style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.4), fontSize: 9)),
          ]),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: widget.onClose,
            child: Icon(Icons.close, size: 16, color: scheme.onSurface.withValues(alpha: 0.3)),
          ),
        ]),

        // Resource bars
        if (resources.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...resources.entries.map((e) {
            final c = e.value >= 0.67 ? const Color(0xFF1D9E75)
                    : e.value >= 0.33 ? const Color(0xFFEF9F27)
                                      : const Color(0xFFE24B4A);
            final name = GameConfig.item(e.key)?.name ?? e.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                SizedBox(width: 90, child: Text(name, style: TextStyle(color: scheme.onSurface, fontSize: 11), overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 6),
                Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(value: e.value,
                        backgroundColor: c.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation(c), minHeight: 5))),
              ]),
            );
          }),
        ],

        // Activity selector
        const SizedBox(height: 10),
        Text('ACTIVITIES', style: TextStyle(fontSize: 9, letterSpacing: 2, color: scheme.primary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...activities.map((a) {
          final sel = _selected.contains(a.id);
          final out = GameConfig.item(a.outputItemId)?.name ?? a.outputItemId;
          return GestureDetector(
            onTap: () => setState(() { if (sel) _selected.remove(a.id); else _selected.add(a.id); }),
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? scheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: sel ? scheme.primary : scheme.primary.withValues(alpha: 0.18),
                  width: sel ? 1.2 : 0.5,
                ),
              ),
              child: Row(children: [
                Text(a.icon, style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a.name, style: TextStyle(
                      color: sel ? scheme.primary : scheme.onSurface, fontSize: 12, fontWeight: FontWeight.w500)),
                  Text('${a.stepsPerNode} steps → $out',
                      style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.4), fontSize: 10)),
                ])),
                if (sel) Icon(Icons.check_circle, color: scheme.primary, size: 16),
              ]),
            ),
          );
        }),

        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Consumer(
            builder: (context, ref, _) {
              final steps = ref.read(navigationProvider.notifier).calculatePathSteps(widget.location.id);
              return ElevatedButton(
                onPressed: () => widget.onGo(_selected.toList()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: scheme.primary.withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                ),
                child: Text(
                  'Head to ${widget.location.name} ($steps steps)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              );
            }
          ),
        ),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
  );
}