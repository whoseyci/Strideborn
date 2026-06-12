import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/combat_config.dart';

class CombatOverlay extends ConsumerStatefulWidget {
  final CombatResult result;
  final VoidCallback onComplete;
  
  const CombatOverlay({super.key, required this.result, required this.onComplete});

  @override
  ConsumerState<CombatOverlay> createState() => _CombatOverlayState();
}

class _CombatOverlayState extends ConsumerState<CombatOverlay> with SingleTickerProviderStateMixin {
  final _scrollCtrl = ScrollController();
  final List<CombatEvent> _visibleEvents = [];
  int _currentIndex = 0;
  Timer? _animTimer;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void didUpdateWidget(CombatOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.result != widget.result) {
      _animTimer?.cancel();
      _visibleEvents.clear();
      _currentIndex = 0;
      _isFinished = false;
      _startAnimation();
    }
  }

  void _startAnimation() {
    _animTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_currentIndex < widget.result.timeline.length) {
        setState(() {
          _visibleEvents.add(widget.result.timeline[_currentIndex]);
          _currentIndex++;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollCtrl.hasClients) {
            _scrollCtrl.animateTo(
              _scrollCtrl.position.maxScrollExtent,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            );
          }
        });
      } else {
        timer.cancel();
        setState(() => _isFinished = true);
      }
    });
  }

  void _skipToEnd() {
    _animTimer?.cancel();
    setState(() {
      _visibleEvents.clear();
      _visibleEvents.addAll(widget.result.timeline);
      _currentIndex = widget.result.timeline.length;
      _isFinished = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _animTimer?.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Widget _buildEventRow(CombatEvent e, ThemeData theme) {
    final scheme = theme.colorScheme;
    Color textColor = scheme.onSurface;
    if (e.type == CombatEventType.heal) textColor = Colors.greenAccent;
    if (e.type == CombatEventType.effectTick) textColor = Colors.orangeAccent;
    if (e.target == 'You' && e.type == CombatEventType.attack) textColor = Colors.redAccent.shade200;
    if (e.actor == 'You' && e.target != 'You' && e.type == CombatEventType.attack) textColor = scheme.primary;
    if (e.type == CombatEventType.stun) textColor = Colors.lightBlueAccent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(e.effectIcon ?? (e.actor == 'You' ? '⚔' : '💢'), style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              e.message,
              style: TextStyle(color: textColor, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    String headerText = 'COMBAT ENCOUNTER';
    Color headerColor = scheme.primary;
    if (_isFinished) {
      if (widget.result is VictoryResult) {
        headerText = 'VICTORY';
        headerColor = Colors.greenAccent;
      } else if (widget.result is DefeatResult) {
        headerText = 'DEFEAT';
        headerColor = Colors.redAccent;
      } else if (widget.result is FleeResult) {
        headerText = 'FLED';
        headerColor = Colors.grey;
      }
    }

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                headerText,
                style: TextStyle(
                  color: headerColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131320),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    itemCount: _visibleEvents.length,
                    itemBuilder: (context, index) {
                      return _buildEventRow(_visibleEvents[index], theme);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isFinished
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: headerColor,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: widget.onComplete,
                        child: const Text('CONTINUE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      )
                    : OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: scheme.onSurface,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          side: BorderSide(color: scheme.onSurface.withValues(alpha: 0.3)),
                        ),
                        onPressed: _skipToEnd,
                        child: const Text('SKIP ANIMATION'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
