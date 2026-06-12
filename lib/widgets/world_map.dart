import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/game_config.dart';
import '../../state/providers/navigation_provider.dart';

// ─────────────────────────────────────────────────────────
// World Map Widget
// Renders the generated 11x11 grid physically onto the canvas.
// Calculates tile positions dynamically by parsing zone IDs.
// ─────────────────────────────────────────────────────────

// Mock player counts — will come from PocketBase later
const Map<String, int> _kPlayerCounts = {};

class WorldMapWidget extends ConsumerStatefulWidget {
  /// Called when any location node is tapped. Null = deselect.
  final ValueChanged<LocationEntity?> onLocationTap;

  const WorldMapWidget({super.key, required this.onLocationTap});

  @override
  ConsumerState<WorldMapWidget> createState() => _WorldMapWidgetState();
}

class _WorldMapWidgetState extends ConsumerState<WorldMapWidget> {
  String? _selectedLocationId;

  void _onNodeTap(String locationId) {
    final loc = GameConfig.location(locationId);
    if (loc == null) return;
    final next = _selectedLocationId == locationId ? null : locationId;
    setState(() => _selectedLocationId = next);
    widget.onLocationTap(next == null ? null : loc);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      return GestureDetector(
        onTapDown: (d) => _handleTap(d.localPosition, size),
        child: CustomPaint(
          size: size,
          painter: _MapPainter(
            selectedLocationId: _selectedLocationId,
            currentLocationId: ref.watch(navigationProvider).currentLocationId,
            travelDestinationId: ref.watch(navigationProvider).travelDestinationId,
            travelProgress: ref.watch(navigationProvider).currentLocation != null ? 
                (1.0 - (ref.watch(navigationProvider).travelStepsRemaining / (ref.watch(navigationProvider).currentLocation?.travelSteps ?? 1)).clamp(0.0, 1.0)) : 0.0,
          ),
        ),
      );
    });
  }

  void _handleTap(Offset tapPos, Size size) {
    for (final loc in GameConfig.allLocations) {
      final nodePos = _MapPainter.getPos(loc.id, size);
      if (nodePos == null) continue;
      
      final clickRadius = loc.isTeleportHub ? 26.0 : 16.0;
      if ((tapPos - nodePos).distance < clickRadius) {
        _onNodeTap(loc.id);
        return;
      }
    }
    // Tap empty space — deselect
    setState(() => _selectedLocationId = null);
    widget.onLocationTap(null);
  }
}

class _MapPainter extends CustomPainter {
  final String? selectedLocationId;
  final String currentLocationId;
  final String? travelDestinationId;
  final double travelProgress;

  _MapPainter({
    required this.selectedLocationId,
    required this.currentLocationId,
    required this.travelDestinationId,
    required this.travelProgress,
  });

  static const _gold      = Color(0xFFD4A84B);
  static const _dimGold   = Color(0x44D4A84B);
  static const _navyLight = Color(0xFF2A2A4E);
  static const _parchment = Color(0xFFE8DCC8);
  static const _safe       = Color(0xFF1D9E75);
  static const _borderlands = Color(0xFFEF9F27);
  static const _cursed     = Color(0xFFE24B4A);

  Color _dangerColor(String danger) {
    switch (danger) {
      case 'safe': return _safe;
      case 'borderlands': return _borderlands;
      case 'cursed': return _cursed;
      default: return const Color(0xFF534AB7);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawGridEdges(canvas, size);
    _drawNodes(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFF141416));
  }

  void _drawGridEdges(Canvas canvas, Size size) {
    final edgePaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.05)
      ..strokeWidth = 1.0;
      
    // Simpler grid mesh renderer:
    final double padding = 40.0;
    final double availW = size.width - padding * 2;
    final double availH = size.height - padding * 2;
    final double minDim = math.min(availW, availH);
    final double step = minDim / 10;
    
    final double offsetX = (size.width - minDim) / 2;
    final double offsetY = (size.height - minDim) / 2;
    
    for (int i = 0; i <= 10; i++) {
        canvas.drawLine(
          Offset(offsetX + i * step, offsetY),
          Offset(offsetX + i * step, offsetY + 10 * step),
          edgePaint,
        );
        canvas.drawLine(
          Offset(offsetX, offsetY + i * step),
          Offset(offsetX + 10 * step, offsetY + i * step),
          edgePaint,
        );
    }
  }

  void _drawNodes(Canvas canvas, Size size) {
    for (final loc in GameConfig.allLocations) {
      final pos = getPos(loc.id, size);
      if (pos == null) continue;

      final isSelected = loc.id == selectedLocationId;
      final isCurrent = loc.id == currentLocationId;
      final isTraveling = travelDestinationId != null && travelDestinationId!.contains(loc.id);
      
      final dc = _dangerColor(loc.danger);

      if (loc.isTeleportHub) {
        // Draw City
        if (isCurrent || isSelected) {
          canvas.drawRect(Rect.fromCenter(center: pos, width: 44, height: 44), Paint()..color = _gold.withValues(alpha: 0.2)..style = PaintingStyle.fill);
        }
        canvas.drawRect(Rect.fromCenter(center: pos, width: 28, height: 28), Paint()..color = isCurrent ? _gold.withValues(alpha: 0.4) : _navyLight..style = PaintingStyle.fill);
        canvas.drawRect(Rect.fromCenter(center: pos, width: 28, height: 28), Paint()..color = isSelected || isCurrent ? _gold : _dimGold..strokeWidth = 2.0..style = PaintingStyle.stroke);
        _drawLabel(canvas, loc.icon, pos - const Offset(0, 2), fontSize: 13);
        
        // Hide name if it clusters too heavily, unless it's a cornerstone
        if (isSelected || loc.id == 'crimson_citadel') {
          _drawLabel(canvas, loc.name, pos + const Offset(0, 22), fontSize: 9, color: isCurrent ? _gold : _parchment.withValues(alpha: 0.8), bold: true);
        }
      } else {
        // Draw Wild Zone as a tile square
        final minDim = math.min(size.width, size.height) - 80.0;
        final step = minDim / 10;

        final tileRect = Rect.fromCenter(center: pos, width: step * 0.9, height: step * 0.9);
        
        if (isSelected || isCurrent || isTraveling) {
          canvas.drawRect(tileRect, Paint()..color = dc.withValues(alpha: 0.3)..style = PaintingStyle.fill);
        }
        canvas.drawRect(Rect.fromCenter(center: pos, width: step * 0.6, height: step * 0.6), Paint()..color = isSelected || isCurrent ? dc : dc.withValues(alpha: 0.4)..style = PaintingStyle.fill);

        if (isSelected) {
          _drawLabel(canvas, 'T${loc.tier}', pos - const Offset(0, 14), fontSize: 8, color: dc);
        }
      }

      if (isCurrent && travelDestinationId != null) {
        canvas.drawArc(
          Rect.fromCircle(center: pos, radius: loc.isTeleportHub ? 16 : 8),
          -1.5708, 2 * 3.14159 * travelProgress, false,
          Paint()..color = _gold..strokeWidth = 2.0..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  static Offset? getPos(String id, Size size) {
    int x = -1, y = -1;
    if (id == 'ironhaven') { x=2; y=2; }
    else if (id == 'ashgrove') { x=8; y=2; }
    else if (id == 'tanners_rest') { x=2; y=8; }
    else if (id == 'silkwatch') { x=8; y=8; }
    else if (id == 'crimson_citadel') { x=5; y=5; }
    else if (id.startsWith('beginner_town_')) {
      final p = id.split('_'); 
      if (p.length >= 4) { x = int.tryParse(p[2]) ?? -1; y = int.tryParse(p[3]) ?? -1; }
    }
    else if (id.startsWith('zone_')) {
      final p = id.split('_'); 
      if (p.length >= 3) { x = int.tryParse(p[1]) ?? -1; y = int.tryParse(p[2]) ?? -1; }
    }
    if (x == -1 || y == -1) return null;

    final double padding = 40.0;
    final double availW = size.width - padding * 2;
    final double availH = size.height - padding * 2;
    final double minDim = math.min(availW, availH);
    final double step = minDim / 10;
    
    final double offsetX = (size.width - minDim) / 2;
    final double offsetY = (size.height - minDim) / 2;
    
    return Offset(offsetX + x * step, offsetY + y * step);
  }

  void _drawLabel(Canvas canvas, String text, Offset pos,
      {double fontSize = 11, Color color = _parchment, bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(
        color: color, fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal, height: 1.0)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint,
      {double dashLen = 6, double gapLen = 4}) {
    final total = (end - start).distance;
    final dir   = (end - start) / total;
    double drawn = 0; bool drawing = true;
    while (drawn < total) {
      final segLen = drawing ? dashLen : gapLen;
      final next   = drawn + segLen;
      if (drawing) canvas.drawLine(start + dir * drawn, start + dir * next.clamp(0, total), paint);
      drawn = next; drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.selectedLocationId != selectedLocationId ||
      old.currentLocationId  != currentLocationId  ||
      old.travelDestinationId != travelDestinationId;
}

// Exposed so MapOverlay can display availability info
int playerCountFor(String locationId) => _kPlayerCounts[locationId] ?? 0;