import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/health_service.dart';
import '../state/providers/navigation_provider.dart';
import '../widgets/overlays/map_overlay.dart';
import '../widgets/overlays/inventory_overlay.dart';
import '../widgets/overlays/menu_overlay.dart';
import '../widgets/overlays/combat_overlay.dart';
import '../widgets/activity_view.dart';
import '../widgets/zone_view/zone_view.dart';

// ═══════════════════════════════════════════════════════
// Main Screen
//
// Zone view fills the entire screen.
// Floating buttons overlay the zone:
//   Map    — upper left
//   Menu   — upper right
//   Bag    — lower right
//   Sync   — lower left
// Zone title hovers top-center as ALLCAPS heading.
// ═══════════════════════════════════════════════════════

enum Overlay { none, map, inventory, menu }

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  Timer? _healthTimer;

  Overlay _overlay = Overlay.none;
  String? _feedback;

  late final AnimationController _mapCtrl;
  late final AnimationController _invCtrl;
  late final AnimationController _menuCtrl;

  late final Animation<Offset> _invSlide;
  late final Animation<Offset> _menuSlide;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _mapCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _invCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _menuCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));

    _invSlide  = Tween(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _invCtrl, curve: Curves.easeOutCubic));
    _menuSlide = Tween(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _menuCtrl, curve: Curves.easeOutCubic));

    _syncHealth();
    _healthTimer = Timer.periodic(const Duration(seconds: 30), (_) => _syncHealth());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncHealth();
    }
  }

  Future<void> _syncHealth() async {
    final prefs = await SharedPreferences.getInstance();
    final lastMs = prefs.getInt('last_health_sync') ?? DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch;
    final lastTime = DateTime.fromMillisecondsSinceEpoch(lastMs);

    final steps = await HealthService.getStepsSince(lastTime);
    if (steps > 0) {
      await ref.read(navigationProvider.notifier).applySteps(steps);
      await prefs.setInt('last_health_sync', DateTime.now().millisecondsSinceEpoch);
      _showFeedback('✅ Synced $steps steps!');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _healthTimer?.cancel();
    _mapCtrl.dispose();
    _invCtrl.dispose();
    _menuCtrl.dispose();
    super.dispose();
  }

  void _openOverlay(Overlay o) {
    if (_overlay == o) { _closeOverlay(); return; }
    _closeImmediate();
    setState(() => _overlay = o);
    switch (o) {
      case Overlay.map:       _mapCtrl.forward();  break;
      case Overlay.inventory: _invCtrl.forward();  break;
      case Overlay.menu:      _menuCtrl.forward(); break;
      case Overlay.none:      break;
    }
  }

  void _closeOverlay() {
    switch (_overlay) {
      case Overlay.map:       _mapCtrl.reverse().then((_)  { if (mounted) setState(() => _overlay = Overlay.none); }); break;
      case Overlay.inventory: _invCtrl.reverse().then((_)  { if (mounted) setState(() => _overlay = Overlay.none); }); break;
      case Overlay.menu:      _menuCtrl.reverse().then((_) { if (mounted) setState(() => _overlay = Overlay.none); }); break;
      case Overlay.none: break;
    }
  }

  void _closeImmediate() {
    _mapCtrl.reset(); _invCtrl.reset(); _menuCtrl.reset();
    _overlay = Overlay.none;
  }

  void _showFeedback(String msg) {
    setState(() => _feedback = msg);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _feedback == msg) setState(() => _feedback = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final safePad  = MediaQuery.of(context).padding;
    final topInset = safePad.top + 8.0;
    final botInset = safePad.bottom + 8.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Stack(
        children: [

          // ── Zone view — full screen background ────
          Positioned.fill(
            child: ZoneView(onFeedback: _showFeedback),
          ),

          // ── Activity panel — node progress + step input ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ActivityView(onFeedback: _showFeedback),
          ),

          // ── Zone title — top center ────────────────
          Positioned(
            top: topInset,
            left: 72,
            right: 72,
            child: _ZoneHeading(),
          ),

          // ── Map button — upper left ────────────────
          Positioned(
            top: topInset,
            left: 12,
            child: _FloatButton(
              icon: Icons.map_outlined,
              label: 'MAP',
              active: _overlay == Overlay.map,
              onTap: () => _openOverlay(Overlay.map),
            ),
          ),

          // ── Menu button — upper right ──────────────
          Positioned(
            top: topInset,
            right: 12,
            child: _FloatButton(
              icon: Icons.menu,
              label: 'MENU',
              active: _overlay == Overlay.menu,
              onTap: () => _openOverlay(Overlay.menu),
            ),
          ),

          // ── Bag button — lower right ───────────────
          Positioned(
            bottom: botInset + 120,
            right: 12,
            child: _FloatButton(
              icon: Icons.backpack_outlined,
              label: 'BAG',
              active: _overlay == Overlay.inventory,
              onTap: () => _openOverlay(Overlay.inventory),
            ),
          ),

          // ── Sync button REMOVED ───────────────

          // ── Overlay backdrop ───────────────────────
          if (_overlay != Overlay.none)
            GestureDetector(
              onTap: _closeOverlay,
              child: AnimatedOpacity(
                opacity: 0.5,
                duration: const Duration(milliseconds: 200),
                child: Container(color: Colors.black),
              ),
            ),

          // ── Map overlay (centered popup) ───────────
          if (_overlay == Overlay.map)
            GestureDetector(
              onTap: _closeOverlay,
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
                child: Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: FadeTransition(
                      opacity: _mapCtrl,
                      child: ScaleTransition(
                        scale: Tween(begin: 0.92, end: 1.0).animate(
                          CurvedAnimation(parent: _mapCtrl, curve: Curves.easeOutCubic)),
                        child: MapOverlay(
                          onClose: _closeOverlay,
                          onFeedback: _showFeedback,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Inventory overlay (slides from right) ──
          SlideTransition(
            position: _invSlide,
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: InventoryOverlay(
                  onClose: _closeOverlay,
                  onFeedback: _showFeedback,
                ),
              ),
            ),
          ),

          // ── Menu overlay (slides from bottom) ──────
          SlideTransition(
            position: _menuSlide,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                width: double.infinity,
                child: MenuOverlay(
                  onClose: _closeOverlay,
                  onFeedback: _showFeedback,
                ),
              ),
            ),
          ),

          // ── Combat overlay (Fullscreen animation) ──────
          if (ref.watch(navigationProvider).lastCombatResult != null)
            CombatOverlay(
              result: ref.watch(navigationProvider).lastCombatResult!,
              onComplete: () {
                ref.read(navigationProvider.notifier).clearCombatResult();
              },
            ),

          // ── Feedback toast ─────────────────────────
          if (_feedback != null)
            Positioned(
              bottom: botInset + 100,
              left: 20,
              right: 20,
              child: AnimatedOpacity(
                opacity: _feedback != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: _FeedbackToast(message: _feedback!),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Zone heading ─────────────────────────────────────────
class _ZoneHeading extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationLabel = ref.watch(navigationProvider).locationLabel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        locationLabel.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFFD4A84B),
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.5,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ── Floating button ──────────────────────────────────────
class _FloatButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FloatButton({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg    = active ? scheme.primary.withValues(alpha: 0.25) : const Color(0xFF0F0F1A).withValues(alpha: 0.80);
    final border = active ? scheme.primary.withValues(alpha: 0.6)  : scheme.primary.withValues(alpha: 0.2);
    final fg    = active ? scheme.primary : scheme.onSurface.withValues(alpha: 0.7);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: 0.75),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: fg, size: 18),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: fg, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
        ]),
      ),
    );
  }
}

// ── Feedback toast ───────────────────────────────────────
class _FeedbackToast extends StatelessWidget {
  final String message;
  const _FeedbackToast({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.4), width: 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 12)],
      ),
      child: Text(message, style: TextStyle(color: scheme.primary, fontSize: 13), textAlign: TextAlign.center),
    );
  }
}