import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/game_config.dart';
import '../../state/providers/navigation_provider.dart';
import '../world_map.dart';
import '../../state/providers/player_provider.dart';
import '../../state/providers/legacy_activity_provider.dart';
import '../../state/providers/inventory_provider.dart';

// ═══════════════════════════════════════════════════════
// Zone View
//
// Birds-eye view of wherever the character currently is.
// City: shows station nodes arranged around a central plaza.
//       Character starts at centre. Tap a station →
//       character slides to it → station detail expands.
// Gathering zone: shows resource nodes, character in middle.
//
// No navigation stack — single canvas that morphs.
// Real art drops in by replacing the background painter.
// ═══════════════════════════════════════════════════════

class ZoneView extends ConsumerStatefulWidget {
  final Function(String) onFeedback;
  const ZoneView({super.key, required this.onFeedback});

  @override
  ConsumerState<ZoneView> createState() => _ZoneViewState();
}

class _ZoneViewState extends ConsumerState<ZoneView>
    with TickerProviderStateMixin {

  // Character position (0,0 = centre of canvas)
  Offset _charPos = Offset.zero;
  String? _selectedStationId;
  String? _pendingStationId;
  OverlayEntry? _panelEntry;

  late AnimationController _charMoveCtrl;
  late Animation<Offset> _charMoveAnim;

  @override
  void initState() {
    super.initState();
    _charMoveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _charMoveAnim = Tween(begin: Offset.zero, end: Offset.zero)
        .animate(CurvedAnimation(parent: _charMoveCtrl, curve: Curves.easeOutCubic));
    _charMoveCtrl.addListener(() => setState(() {
      _charPos = _charMoveAnim.value;
    }));
    _charMoveCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && _pendingStationId != null && mounted) {
        setState(() => _selectedStationId = _pendingStationId);
        _showPanel(_pendingStationId!);
        _pendingStationId = null;
      }
    });
  }

  @override
  void dispose() {
    _hidePanel();
    _charMoveCtrl.dispose();
    super.dispose();
  }

  void _moveTo(Offset target, String? stationId) {
    _pendingStationId = stationId;
    _charMoveAnim = Tween(begin: _charPos, end: target)
        .animate(CurvedAnimation(parent: _charMoveCtrl, curve: Curves.easeOutCubic));
    _charMoveCtrl.forward(from: 0);
    setState(() => _selectedStationId = null);
  }

  void _showPanel(String stationId) {
    _hidePanel();
    _panelEntry = OverlayEntry(builder: (_) => Stack(children: [
      // Tap-outside barrier — covers buttons and activity bar
      Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _closePanel,
          child: Container(color: Colors.black.withValues(alpha: 0.45)),
        ),
      ),
      // Panel — above everything
      Positioned(
        bottom: 0, left: 0, right: 0,
        child: Material(
          elevation: 16,
          color: Colors.transparent,
          child: stationId == '__travel_agent__'
              ? _TravelAgentPanel(onClose: _closePanel, onFeedback: widget.onFeedback)
              : _StationPanel(stationId: stationId, onClose: _closePanel, onFeedback: widget.onFeedback),
        ),
      ),
    ]));
    Overlay.of(context).insert(_panelEntry!);
  }

  void _hidePanel() {
    _panelEntry?.remove();
    _panelEntry = null;
  }

  void _closePanel() {
    _pendingStationId = null;
    _hidePanel();
    _returnToCenter();
  }

  void _returnToCenter() {
    _moveTo(Offset.zero, null);
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(navigationProvider).currentLocation;
    if (loc == null) return const SizedBox.shrink();

    final isHub = loc.isTeleportHub;

    return Stack(children: [
      // ── Background ─────────────────────────────────
      CustomPaint(
        painter: _ZoneBgPainter(location: loc, charPos: _charPos),
        child: Container(),
      ),

      // ── Station / node layer ────────────────────────
      isHub
          ? _HubStationLayer(
              location: loc,
              charPos: _charPos,
              selectedStationId: _selectedStationId,
              onStationTap: (stationId, offset) {
                _moveTo(offset, stationId);
              },
            )
          : _GatheringNodeLayer(
              location: loc,
              charPos: _charPos,
            ),

      // ── Character sprite ────────────────────────────
      _CharacterSprite(pos: _charPos),

      // ── Combat filter toggle (only in non-hub zones) 
      if (!isHub)
        const Positioned(
          top: 16, right: 16,
          child: _CombatToggle(),
        ),
    ]);
  }
}

// ── Background painter ───────────────────────────────────
class _ZoneBgPainter extends CustomPainter {
  final LocationEntity location;
  final Offset charPos;

  _ZoneBgPainter({required this.location, required this.charPos});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Background fill — colour varies by zone type
    final bgColor = _bgColor();
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = bgColor);

    if (location.isTeleportHub) {
      // City: draw plaza circle + cobblestone hint
      _drawCityBg(canvas, cx, cy, size);
    } else {
      // Zone: draw terrain
      _drawZoneBg(canvas, cx, cy, size);
    }
  }

  void _drawCityBg(Canvas canvas, double cx, double cy, Size size) {
    // Outer ground
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFF2A2215));

    // Plaza circle
    canvas.drawCircle(Offset(cx, cy), size.width * 0.35,
        Paint()..color = const Color(0xFF3A3020));
    canvas.drawCircle(Offset(cx, cy), size.width * 0.35,
        Paint()..color = const Color(0xFFD4A84B).withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Path lines from center to edges (cobblestone roads)
    final roadPaint = Paint()
      ..color = const Color(0xFF4A4030).withValues(alpha: 0.6)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2 + math.pi / 4;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + math.cos(angle) * size.width, cy + math.sin(angle) * size.width),
        roadPaint,
      );
    }

    // Inner circle (fountain / plaza centre)
    canvas.drawCircle(Offset(cx, cy), 18,
        Paint()..color = const Color(0xFF4A4030));
    canvas.drawCircle(Offset(cx, cy), 18,
        Paint()..color = const Color(0xFFD4A84B).withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  void _drawZoneBg(Canvas canvas, double cx, double cy, Size size) {
    // Terrain patches
    final terrainPaint = Paint()..color = const Color(0xFF1A2A1A);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), terrainPaint);

    // Random-ish terrain features (placeholder for real art)
    final featurePaint = Paint()..color = const Color(0xFF243020).withValues(alpha: 0.8);
    final rng = math.Random(location.id.hashCode);
    for (int i = 0; i < 8; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = 20 + rng.nextDouble() * 40;
      canvas.drawCircle(Offset(x, y), r, featurePaint);
    }
  }

  Color _bgColor() {
    switch (location.danger) {
      case 'none': return const Color(0xFF2A2215);
      case 'safe': return const Color(0xFF1A2A1A);
      case 'borderlands': return const Color(0xFF2A2010);
      case 'cursed': return const Color(0xFF1A1020);
      default: return const Color(0xFF0A0A1A);
    }
  }

  @override
  bool shouldRepaint(_ZoneBgPainter old) =>
      old.location.id != location.id;
}

// ── Hub station layer ────────────────────────────────────
class _HubStationLayer extends StatelessWidget {
  final LocationEntity location;
  final Offset charPos;
  final String? selectedStationId;
  final Function(String stationId, Offset canvasOffset) onStationTap;

  const _HubStationLayer({
    required this.location,
    required this.charPos,
    required this.selectedStationId,
    required this.onStationTap,
  });

  @override
  Widget build(BuildContext context) {
    final stations = GameConfig.stationsAt(location.id);
    return LayoutBuilder(builder: (ctx, constraints) {
      final cx = constraints.maxWidth / 2;
      final cy = constraints.maxHeight / 2;
      final radius = constraints.maxWidth * 0.30;
      // Include travel agent as the last slot in the circle
      final totalSlots = stations.length + 1;
      final angleStep  = 2 * math.pi / math.max(totalSlots, 1);

      return Stack(children: [
        // Regular station nodes
        for (int i = 0; i < stations.length; i++) ...[
          () {
            final angle = -math.pi / 2 + angleStep * i;
            final sx = cx + math.cos(angle) * radius;
            final sy = cy + math.sin(angle) * radius;
            final st = stations[i];
            final isSelected = selectedStationId == st.id;
            final localOffset = Offset(sx - cx, sy - cy);

            return Positioned(
              left: sx - 36,
              top: sy - 36,
              child: GestureDetector(
                onTap: () => onStationTap(st.id, localOffset),
                child: _StationNode(station: st, selected: isSelected),
              ),
            );
          }(),
        ],
        // Travel agent node — last slot in circle
        () {
          final angle = -math.pi / 2 + angleStep * stations.length;
          final sx = cx + math.cos(angle) * radius;
          final sy = cy + math.sin(angle) * radius;
          final isSelected = selectedStationId == '__travel_agent__';
          final localOffset = Offset(sx - cx, sy - cy);
          return Positioned(
            left: sx - 36,
            top: sy - 36,
            child: GestureDetector(
              onTap: () => onStationTap('__travel_agent__', localOffset),
              child: _TravelAgentNode(selected: isSelected),
            ),
          );
        }(),
      ]);
    });
  }
}

class _StationNode extends StatelessWidget {
  final StationEntity station;
  final bool selected;
  const _StationNode({required this.station, required this.selected});

  @override
  Widget build(BuildContext context) {
    final gold = const Color(0xFFD4A84B);
    final green = const Color(0xFF1D9E75);
    final accent = station.isCrafting ? gold : green;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: selected
            ? accent.withValues(alpha: 0.25)
            : const Color(0xFF1A1A2E).withValues(alpha: 0.85),
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? accent : accent.withValues(alpha: 0.4),
          width: selected ? 2.5 : 1.0,
        ),
        boxShadow: selected
            ? [BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 12)]
            : [],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(station.icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 2),
        Text(
          station.name,
          style: TextStyle(
            color: selected ? accent : const Color(0xFFE8DCC8).withValues(alpha: 0.7),
            fontSize: 8,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ]),
    );
  }
}

// ── Travel agent node ────────────────────────────────────
class _TravelAgentNode extends StatelessWidget {
  final bool selected;
  const _TravelAgentNode({required this.selected});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7B68EE); // purple — distinct from crafting gold / refining green
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: selected
            ? accent.withValues(alpha: 0.25)
            : const Color(0xFF1A1A2E).withValues(alpha: 0.85),
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? accent : accent.withValues(alpha: 0.4),
          width: selected ? 2.5 : 1.0,
        ),
        boxShadow: selected ? [BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 12)] : [],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🧭', style: TextStyle(fontSize: 22)),
        const SizedBox(height: 2),
        Text(
          'Travel\nAgent',
          style: TextStyle(
            color: selected ? accent : const Color(0xFFE8DCC8).withValues(alpha: 0.7),
            fontSize: 8,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ]),
    );
  }
}

// ── Travel agent panel ───────────────────────────────────
class _TravelAgentPanel extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final Function(String) onFeedback;
  const _TravelAgentPanel({required this.onClose, required this.onFeedback});

  @override
  ConsumerState<_TravelAgentPanel> createState() => _TravelAgentPanelState();
}

class _TravelAgentPanelState extends ConsumerState<_TravelAgentPanel> {
  LocationEntity? _pendingHub;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final currentLocationId = ref.watch(navigationProvider).currentLocationId;
    const accent = Color(0xFF7B68EE);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: accent.withValues(alpha: 0.25))),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle — tap or drag down to close
        GestureDetector(
          onTap: widget.onClose,
          onVerticalDragEnd: (d) { if ((d.primaryVelocity ?? 0) > 200) widget.onClose(); },
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(color: scheme.onSurface.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)))),
          ),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Row(children: [
            const Text('🧭', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Travel Agent', style: TextStyle(color: scheme.onSurface, fontSize: 17, fontWeight: FontWeight.bold)),
              Text('Free · pricing coming soon', style: TextStyle(color: accent.withValues(alpha: 0.8), fontSize: 11)),
            ])),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'TAP A CITY TO SELECT A DESTINATION',
            style: TextStyle(color: accent.withValues(alpha: 0.45), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
        ),
        const SizedBox(height: 8),
        // World map — tap a hub to stage it
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 240,
              child: WorldMapWidget(
                onLocationTap: (loc) {
                  if (loc == null || !loc.isTeleportHub) return;
                  if (loc.id == currentLocationId) return;
                  setState(() => _pendingHub = loc);
                },
              ),
            ),
          ),
        ),
        // Confirm row — slides in when a hub is selected
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: _pendingHub == null
              ? const SizedBox(height: 16)
              : Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accent.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      Text(_pendingHub!.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_pendingHub!.name,
                            style: TextStyle(color: scheme.onSurface, fontSize: 13, fontWeight: FontWeight.bold)),
                        Text('Free · for now',
                            style: TextStyle(color: accent.withValues(alpha: 0.6), fontSize: 11)),
                      ])),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final hub = _pendingHub!;
                          ref.read(navigationProvider.notifier).teleportToHub(hub.id);
                          widget.onClose();
                          widget.onFeedback('Teleported to ${hub.name}!');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                          elevation: 0,
                        ),
                        child: const Text('Teleport', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ]),
                  ),
                ),
        ),
      ]),
    );
  }
}

// ── Combat Toggle ────────────────────────────────────────
class _CombatToggle extends ConsumerWidget {
  const _CombatToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navigationProvider);
    final isEnabled = navState.combatEnabled;
    final gold = const Color(0xFFD4A84B);

    return GestureDetector(
      onTap: () => ref.read(navigationProvider.notifier).toggleCombat(!isEnabled),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isEnabled ? gold.withValues(alpha: 0.15) : const Color(0xFF1A1A2E).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEnabled ? gold : gold.withValues(alpha: 0.3),
            width: isEnabled ? 1.5 : 1.0,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('⚔', style: TextStyle(fontSize: 16, color: isEnabled ? gold : Colors.grey)),
          const SizedBox(width: 8),
          Text(
            isEnabled ? 'Combat: ON' : 'Combat: OFF',
            style: TextStyle(
              color: isEnabled ? gold : const Color(0xFFE8DCC8).withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Gathering node layer ─────────────────────────────────
class _GatheringNodeLayer extends ConsumerWidget {
  final LocationEntity location;
  final Offset charPos;

  const _GatheringNodeLayer({required this.location, required this.charPos});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = GameConfig.gatheringAt(location.id);
    return LayoutBuilder(builder: (ctx, constraints) {
      final cx = constraints.maxWidth / 2;
      final cy = constraints.maxHeight / 2;
      final radius = constraints.maxWidth * 0.28;
      final angleStep = 2 * math.pi / math.max(activities.length, 1);
      final navState = ref.watch(navigationProvider);

      return Stack(children: [
        for (int i = 0; i < activities.length; i++) ...[
          () {
            final angle = -math.pi / 2 + angleStep * i;
            final sx = cx + math.cos(angle) * radius;
            final sy = cy + math.sin(angle) * radius;
            final a = activities[i];
            
            // Map node visually functions as a filter toggle
            final isActive = navState.enabledGatherIds.contains(a.id);

            return Positioned(
              left: sx - 36,
              top: sy - 36,
              child: GestureDetector(
                onTap: () {
                  ref.read(navigationProvider.notifier).toggleGatherFilter(a.id);
                },
                child: _GatheringNode(
                  activity: a,
                  active: isActive,
                  progress: 0.0, // Gathering no longer holds isolated progress
                ),
              ),
            );
          }(),
        ],
      ]);
    });
  }
}

class _GatheringNode extends StatelessWidget {
  final ActivityEntity activity;
  final bool active;
  final double progress;
  const _GatheringNode({required this.activity, required this.active, required this.progress});

  @override
  Widget build(BuildContext context) {
    final gold = const Color(0xFFD4A84B);
    return Stack(children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: active
              ? gold.withValues(alpha: 0.2)
              : const Color(0xFF1A1A2E).withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? gold : gold.withValues(alpha: 0.3),
            width: active ? 2.0 : 0.5,
          ),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(activity.icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 2),
          Text(
            GameConfig.item(activity.outputItemId)?.name ?? activity.outputItemId,
            style: TextStyle(
              color: active ? gold : const Color(0xFFE8DCC8).withValues(alpha: 0.6),
              fontSize: 7,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ]),
      ),
      // Progress arc
      if (active && progress > 0)
        SizedBox(
          width: 72,
          height: 72,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation(gold),
          ),
        ),
    ]);
  }
}

// ── Character sprite ─────────────────────────────────────
class _CharacterSprite extends StatelessWidget {
  final Offset pos;
  const _CharacterSprite({required this.pos});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final cx = constraints.maxWidth / 2 + pos.dx;
      final cy = constraints.maxHeight / 2 + pos.dy;
      return Stack(children: [
        Positioned(
          left: cx - 20,
          top: cy - 24,
          child: _CharacterFigure(),
        ),
      ]);
    });
  }
}

class _CharacterFigure extends StatelessWidget {
  const _CharacterFigure();

  @override
  Widget build(BuildContext context) {
    final gold = const Color(0xFFD4A84B);
    // Geometric placeholder — swap for real sprite later
    return SizedBox(
      width: 40,
      height: 48,
      child: CustomPaint(painter: _CharPainter(color: gold)),
    );
  }
}

class _CharPainter extends CustomPainter {
  final Color color;
  const _CharPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Head
    canvas.drawCircle(Offset(size.width / 2, 9), 9, paint);
    canvas.drawCircle(Offset(size.width / 2, 9), 9, outline);

    // Body
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width / 2 - 9, 20, 18, 18),
      const Radius.circular(3),
    );
    canvas.drawRRect(body, paint);
    canvas.drawRRect(body, outline);

    // Legs
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width / 2 - 9, 40, 8, 8), const Radius.circular(2)),
      paint..color = color.withValues(alpha: 0.8));
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width / 2 + 1, 40, 8, 8), const Radius.circular(2)),
      paint..color = color.withValues(alpha: 0.8));
  }

  @override
  bool shouldRepaint(_CharPainter old) => old.color != color;
}

// ── Station detail panel ─────────────────────────────────
class _StationPanel extends StatelessWidget {
  final String stationId;
  final VoidCallback onClose;
  final Function(String) onFeedback;

  const _StationPanel({
    required this.stationId,
    required this.onClose,
    required this.onFeedback,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final station = GameConfig.station(stationId);
    if (station == null) return const SizedBox.shrink();

    final activities = station.activityIds
        .map((id) => GameConfig.activity(id))
        .whereType<ActivityEntity>()
        .toList();

    final typeLabel = station.isCrafting ? 'Crafting' : 'Refining';
    final typeColor = station.isCrafting
        ? scheme.primary
        : const Color(0xFF1D9E75);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: scheme.primary.withValues(alpha: 0.2))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle — tap or drag down to close
          GestureDetector(
            onTap: onClose,
            onVerticalDragEnd: (d) { if ((d.primaryVelocity ?? 0) > 200) onClose(); },
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Center(child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              )),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(children: [
              Text(station.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(station.name, style: TextStyle(color: scheme.onSurface, fontSize: 17, fontWeight: FontWeight.bold)),
                Text(typeLabel, style: TextStyle(color: typeColor, fontSize: 11, fontWeight: FontWeight.w500)),
              ])),
            ]),
          ),
          const SizedBox(height: 4),
          // Activities
          if (activities.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('No activities yet.', style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.4), fontSize: 13)),
            )
          else
            SizedBox(
              height: 220,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: activities.map((a) => _ActivityTile(
                  activity: a,
                  station: station,
                  onFeedback: onFeedback,
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActivityTile extends ConsumerWidget {
  final ActivityEntity activity;
  final StationEntity station;
  final Function(String) onFeedback;

  const _ActivityTile({
    required this.activity,
    required this.station,
    required this.onFeedback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final legacyState = ref.watch(legacyActivityProvider);
    final invState = ref.watch(inventoryProvider);
    final playerState = ref.watch(playerProvider);
    
    final output = GameConfig.item(activity.outputItemId);
    final isActiveWalk = legacyState.walkToCraftActivityId == activity.id;
    final progress = isActiveWalk ? legacyState.walkProgress : 0;
    final progressFraction = isActiveWalk && activity.stepsPerNode > 0
        ? (progress / activity.stepsPerNode).clamp(0.0, 1.0)
        : 0.0;

    bool materialsOk = true;
    for (final e in activity.inputItems.entries) {
      if ((invState.inventory[e.key] ?? 0) < e.value) { materialsOk = false; break; }
    }
    final canInstant = materialsOk && playerState.stepBank >= activity.stepsPerNode;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActiveWalk
            ? scheme.primary.withValues(alpha: 0.08)
            : const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActiveWalk
              ? scheme.primary
              : scheme.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(activity.icon),
          const SizedBox(width: 8),
          Expanded(child: Text(activity.name,
              style: TextStyle(color: scheme.onSurface, fontSize: 13, fontWeight: FontWeight.w500))),
          Text('→ ${output?.name ?? activity.outputItemId}',
              style: TextStyle(color: scheme.primary.withValues(alpha: 0.7), fontSize: 11)),
        ]),
        if (activity.inputItems.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 4, children: activity.inputItems.entries.map((e) {
            final have = invState.inventory[e.key] ?? 0;
            final ok = have >= e.value;
            return _Pill(
              label: '${e.value}× ${GameConfig.item(e.key)?.name ?? e.key} ($have)',
              ok: ok,
            );
          }).toList()),
        ],
        // Progress bar if in progress
        if (progressFraction > 0) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progressFraction,
              backgroundColor: scheme.primary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(scheme.primary),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 2),
          Text('$progress / ${activity.stepsPerNode} steps',
              style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.4), fontSize: 10)),
        ],
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: canInstant ? () async {
                final steps = activity.stepsPerNode;
                ref.read(playerProvider.notifier).updateStepBank(playerState.stepBank - steps);
                for (final e in activity.inputItems.entries) {
                  ref.read(inventoryProvider.notifier).upsertInventoryItem(e.key, -e.value);
                }
                ref.read(inventoryProvider.notifier).upsertInventoryItem(activity.outputItemId, 1);
                onFeedback('✓ Crafted ${output?.name ?? activity.outputItemId}');
              } : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: canInstant ? scheme.primary : scheme.onSurface.withValues(alpha: 0.3),
                side: BorderSide(color: canInstant ? scheme.primary.withValues(alpha: 0.4) : scheme.onSurface.withValues(alpha: 0.08)),
                padding: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Instant (${activity.stepsPerNode})', style: const TextStyle(fontSize: 11)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: materialsOk ? () {
                if (isActiveWalk) {
                  ref.read(legacyActivityProvider.notifier).cancelWalkToCraft();
                } else {
                  ref.read(legacyActivityProvider.notifier).startWalkToCraft(activity.id);
                }
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isActiveWalk
                    ? scheme.primary
                    : scheme.primary.withValues(alpha: materialsOk ? 0.6 : 0.2),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                isActiveWalk ? '🚶 $progress/${activity.stepsPerNode}' : 'Walk to craft',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool ok;
  const _Pill({required this.label, required this.ok});
  @override
  Widget build(BuildContext context) {
    final color = ok ? const Color(0xFF1D9E75) : const Color(0xFFE24B4A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}