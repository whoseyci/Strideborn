import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../state/providers/inventory_provider.dart';
import '../../state/providers/player_provider.dart';
import '../../config/game_config.dart';

// ═══════════════════════════════════════════════════════
// Inventory Overlay
//
// Slides in from the right.
// Top: Character silhouette with 6 gear slots positioned around it.
// Below: Scrollable inventory grouped by category.
// Bottom tab: Stats.
// You are what you wear — any item fits any slot.
// ═══════════════════════════════════════════════════════

class InventoryOverlay extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final Function(String) onFeedback;
  const InventoryOverlay({super.key, required this.onClose, required this.onFeedback});

  @override
  ConsumerState<InventoryOverlay> createState() => _InventoryOverlayState();
}

class _InventoryOverlayState extends ConsumerState<InventoryOverlay> {
  int _tab = 0; // 0=gear+inv, 1=stats

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: double.infinity,
      color: const Color(0xFF0F0F1A),
      child: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(children: [
              IconButton(icon: Icon(Icons.close, color: scheme.onSurface.withValues(alpha: 0.5), size: 20), onPressed: widget.onClose),
              const SizedBox(width: 4),
              _TabChip(label: 'Gear & Items', active: _tab == 0, onTap: () => setState(() => _tab = 0)),
              const SizedBox(width: 8),
              _TabChip(label: 'Stats', active: _tab == 1, onTap: () => setState(() => _tab = 1)),
              const Spacer(),
              Text('${ref.watch(inventoryProvider).totalIP} IP', style: TextStyle(color: scheme.primary, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
            ]),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _tab == 0
                ? _GearAndInventoryPanel(onFeedback: widget.onFeedback, onChanged: () => setState(() {}))
                : _StatsPanel(),
          ),
        ]),
      ),
    );
  }
}

// ── Gear + Inventory panel ────────────────────────────────
class _GearAndInventoryPanel extends StatelessWidget {
  final Function(String) onFeedback;
  final VoidCallback onChanged;
  const _GearAndInventoryPanel({required this.onFeedback, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Character + gear slots
        SliverToBoxAdapter(child: _CharacterGearView(onFeedback: onFeedback, onChanged: onChanged)),
        // Stats strip
        SliverToBoxAdapter(child: _StatsStrip()),
        // Divider
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            Expanded(child: Divider(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('INVENTORY', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
            ),
            Expanded(child: Divider(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15))),
          ]),
        )),
        // Inventory items
        _InventorySliver(onFeedback: onFeedback, onChanged: onChanged),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ── Stats strip (replaces the removed bottom HUD) ────────
class _StatsStrip extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final playerState = ref.watch(playerProvider);
    final invState = ref.watch(inventoryProvider);
    String fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(children: [
        _StatCell(icon: '👟', label: 'BANK',   value: fmt(playerState.stepBank)),
        _StatCell(icon: '⚡', label: 'TOKENS', value: '${playerState.tokenBank}'),
        _StatCell(icon: '🪙', label: 'GOLD',   value: fmt(playerState.gold)),
        _StatCell(icon: '⚔', label: 'IP',     value: '${invState.totalIP}'),
        const Spacer(),
        GestureDetector(
          onTap: () async {
            // Toast shows via MainScreen background sync loop
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.3), width: 0.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.favorite, color: scheme.primary, size: 12),
              const SizedBox(width: 4),
              Text('SYNC', style: TextStyle(color: scheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _StatCell({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: const TextStyle(fontSize: 13)),
        Text(value, style: TextStyle(color: scheme.onSurface, fontSize: 11, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.35), fontSize: 8, letterSpacing: 0.5)),
      ]),
    );
  }
}

// ── Character silhouette + gear slots ─────────────────────
class _CharacterGearView extends ConsumerWidget {
  final Function(String) onFeedback;
  final VoidCallback onChanged;
  const _CharacterGearView({required this.onFeedback, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final invState = ref.watch(inventoryProvider);

    // Slot layout: fractional positions within the character area.
    // fx/fy are the slot-centre fractions; the Positioned offset subtracts 24
    // (half of the 48px button) so keep fx >= 0.08 and fy >= 0.10 to stay
    // fully on-screen at typical widths (320–414 dp).
    const slotLayout = [
      ('helmet',  0.50, 0.10),  // top centre
      ('weapon',  0.13, 0.30),  // left upper
      ('chest',   0.13, 0.58),  // left lower
      ('offhand', 0.87, 0.30),  // right upper
      ('legs',    0.87, 0.58),  // right lower
      ('boots',   0.50, 0.90),  // bottom centre
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.15)),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final w = constraints.maxWidth;
        // Height = width × 1.1 — portrait aspect that gives the gear slots
        // enough room. Model size is controlled in character_viewer.html.
        final h = w * 1.1;
        return SizedBox(
          height: h,
          child: Stack(children: [
            // 3D character model (tap to punch)
            const Positioned.fill(child: _Character3DView()),

            // Gear slots scaled to actual container dimensions
            ...slotLayout.map((s) {
              final (slot, fx, fy) = s;
              final item = invState.gearSlots[slot] != null ? GameConfig.item(invState.gearSlots[slot]!) : null;
              return Positioned(
                left: fx * w - 24,
                top: fy * h - 24,
                child: _GearSlotButton(
                  slot: slot,
                  item: item,
                  onTap: () => _showSlotMenu(context, ref, slot, onFeedback, onChanged),
                ),
              );
            }),
          ]),
        );
      }),
    );
  }

  void _showSlotMenu(BuildContext context, WidgetRef ref, String slot, Function(String) onFeedback, VoidCallback onChanged) {
    final invState = ref.watch(inventoryProvider);
    final scheme = Theme.of(context).colorScheme;
    final currentItem = invState.gearSlots[slot] != null ? GameConfig.item(invState.gearSlots[slot]!) : null;
    final equippable = invState.equippableInInventory; // any item, any slot

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(slot.toUpperCase(), style: TextStyle(color: scheme.primary, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (currentItem != null) ...[
            _EquipOptionTile(
              icon: currentItem.icon,
              name: currentItem.name,
              subtitle: 'Currently equipped  ·  ${currentItem.baseIp} IP',
              trailing: TextButton(
                onPressed: () {
                  final r = ref.read(inventoryProvider.notifier).unequip(slot);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  onFeedback(r);
                  onChanged();
                },
                child: const Text('Unequip', style: TextStyle(color: Color(0xFFE24B4A))),
              ),
            ),
            const Divider(height: 16),
          ],
          if (equippable.isEmpty)
            Text('No equippable items in inventory.', style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.4), fontSize: 13))
          else ...[
            Text('Equip from inventory:', style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.5), fontSize: 12)),
            const SizedBox(height: 8),
            ...equippable.map((item) => _EquipOptionTile(
              icon: item.icon,
              name: item.name,
              subtitle: 'T${item.tier}  ·  ${item.baseIp} IP  ·  ${invState.inventory[item.id] ?? 0}×',
              trailing: ElevatedButton(
                onPressed: () {
                  final r = ref.read(inventoryProvider.notifier).equip(item.id);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  onFeedback(r);
                  onChanged();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary, foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Equip', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            )),
          ],
        ]),
      ),
    );
  }
}

// ── 3D character view ─────────────────────────────────────
// Custom Three.js scene in an InAppWebView (character_viewer.html).
//
// Why not flutter_3d_controller:
//   - Its WebView swallows GestureDetector taps (punch never fired).
//   - It has no API for toggling mesh visibility or swapping bone geometry.
//
// Armor swap: when gear is equipped, we send the slot→model map to JS.
// JS hides the matching base-character bone meshes and parents cloned armor
// meshes onto those same bones. If an item has no 'model' field, the base
// character shows through for that slot (fallback).
//
// Tap: handled via a JS click listener that calls back to Flutter, then
// Flutter sends a 'punch' message back to JS — bypasses the WebView tap issue.
class _Character3DView extends ConsumerStatefulWidget {
  const _Character3DView();
  @override
  ConsumerState<_Character3DView> createState() => _Character3DViewState();
}

class _Character3DViewState extends ConsumerState<_Character3DView> {
  // InAppLocalhostServer serves Flutter assets over real HTTP on localhost,
  // which is the only approach that works reliably on iOS WKWebView.
  // Port 8585 is arbitrary — change if it conflicts with another service.
  static const _port = 8585;
  static final _server = InAppLocalhostServer(port: _port);

  InAppWebViewController? _webController;
  bool _modelReady = false;

  @override
  void initState() {
    super.initState();
    _server.start();
  }

  @override
  void dispose() {
    _server.close();
    super.dispose();
  }

  Map<String, String?> _buildArmorMap() {
    final slots = ref.read(inventoryProvider).gearSlots;
    return {
      for (final e in slots.entries)
        e.key: e.value != null ? GameConfig.item(e.value!)?.model : null,
    };
  }

  void _sendArmorUpdate() {
    if (_webController == null || !_modelReady) return;
    final payload = jsonEncode({'type': 'updateArmor', 'equipped': _buildArmorMap()});
    _webController!.evaluateJavascript(source: 'handleMessage($payload);null');
  }

  void _sendPunch() {
    if (_webController == null || !_modelReady) return;
    _webController!.evaluateJavascript(source: 'handleMessage({"type":"punch"});null');
  }


  @override
  Widget build(BuildContext context) {
    ref.listen<InventoryState>(inventoryProvider, (prev, next) {
      if (prev?.gearSlots != next.gearSlots) _sendArmorUpdate();
    });

    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri('http://localhost:$_port/assets/character_viewer.html'),
      ),
      initialSettings: InAppWebViewSettings(
        transparentBackground: true,
        javaScriptEnabled: true,
        disableContextMenu: true,
        supportZoom: false,
        mediaPlaybackRequiresUserGesture: false,
      ),
      onWebViewCreated: (controller) {
        debugPrint('[3D] onWebViewCreated fired');
        _webController = controller;

        controller.addJavaScriptHandler(
          handlerName: 'onModelReady',
          callback: (_) {
            debugPrint('[3D] onModelReady fired');
            _modelReady = true;
            _sendArmorUpdate();
          },
        );

        controller.addJavaScriptHandler(
          handlerName: 'onTap',
          callback: (_) => _sendPunch(),
        );
      },
      onConsoleMessage: (controller, msg) =>
          debugPrint('[3D:${msg.messageLevel}] ${msg.message}'),
      onLoadStop: (controller, url) =>
          debugPrint('[3D] page loaded: $url'),
      onReceivedError: (controller, req, err) =>
          debugPrint('[3D] load error: ${err.description} — ${req.url}'),
    );
  }
}

class _GearSlotButton extends StatelessWidget {
  final String slot;
  final ItemEntity? item;
  final VoidCallback onTap;
  const _GearSlotButton({required this.slot, required this.item, required this.onTap});

  String get _slotIcon => switch (slot) {
    'helmet'  => '🪖',
    'weapon'  => '⚔',
    'chest'   => '🥋',
    'offhand' => '🛡',
    'legs'    => '👖',
    'boots'   => '👢',
    _         => '📦',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final equipped = item != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: equipped ? scheme.primary.withValues(alpha: 0.18) : const Color(0xFF0F0F1A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: equipped ? scheme.primary.withValues(alpha: 0.5) : scheme.primary.withValues(alpha: 0.15),
            width: equipped ? 1.5 : 1.0,
          ),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(item?.icon ?? _slotIcon, style: TextStyle(fontSize: equipped ? 18 : 14, color: equipped ? null : Colors.white.withValues(alpha: 0.2))),
          if (equipped)
            Text(slot, style: TextStyle(fontSize: 7, color: scheme.primary.withValues(alpha: 0.6))),
        ]),
      ),
    );
  }
}

class _EquipOptionTile extends StatelessWidget {
  final String icon, name, subtitle;
  final Widget trailing;
  const _EquipOptionTile({required this.icon, required this.name, required this.subtitle, required this.trailing});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: TextStyle(color: scheme.onSurface, fontSize: 13, fontWeight: FontWeight.w500)),
          Text(subtitle, style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.4), fontSize: 11)),
        ])),
        trailing,
      ]),
    );
  }
}

// ── Inventory grid (5 × 6 = 30 slots) ────────────────────
class _InventorySliver extends ConsumerWidget {
  final Function(String) onFeedback;
  final VoidCallback onChanged;
  const _InventorySliver({required this.onFeedback, required this.onChanged});

  static const _cols   = 5;
  static const _slots  = 30; // always rendered, empty cells shown as blank

  static const _roman = ['', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'];
  static String _toRoman(int t) => (t >= 0 && t < _roman.length) ? _roman[t] : '$t';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invState = ref.watch(inventoryProvider);

    // Build sorted list of item entries with quantity > 0
    final filled = invState.inventory.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) {
        final ia = GameConfig.item(a.key);
        final ib = GameConfig.item(b.key);
        final catOrder = ['gear', 'processed', 'raw', 'consumable', 'artifact'];
        final ca = catOrder.indexOf(ia?.category ?? '');
        final cb = catOrder.indexOf(ib?.category ?? '');
        if (ca != cb) return ca.compareTo(cb);
        return (ia?.tier ?? 0).compareTo(ib?.tier ?? 0);
      });

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _cols,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 1,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            if (i >= _slots) return null;
            if (i >= filled.length) return const _EmptyInventoryCell();
            final e = filled[i];
            final item = GameConfig.item(e.key);
            return _InventoryCell(
              itemId: e.key,
              item: item,
              qty: e.value,
              onFeedback: onFeedback,
              onChanged: onChanged,
            );
          },
          childCount: _slots,
        ),
      ),
    );
  }
}

class _EmptyInventoryCell extends StatelessWidget {
  const _EmptyInventoryCell();
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.06)),
      ),
    );
  }
}

class _InventoryCell extends ConsumerWidget {
  final String itemId;
  final ItemEntity? item;
  final int qty;
  final Function(String) onFeedback;
  final VoidCallback onChanged;
  const _InventoryCell({
    required this.itemId,
    required this.item,
    required this.qty,
    required this.onFeedback,
    required this.onChanged,
  });

  static const _roman = ['', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'];
  static String _toRoman(int t) => (t >= 0 && t < _roman.length) ? _roman[t] : '$t';

  void _showDetail(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final recipe = item?.recipe;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(children: [
              Text(item?.icon ?? '📦', style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item?.name ?? itemId, style: TextStyle(color: scheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  [
                    if (item?.tier != null) 'Tier ${_toRoman(item!.tier)}',
                    if (item?.category != null) item!.category,
                    if (item?.gearSlot != null) item!.gearSlot!,
                  ].join('  ·  '),
                  style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.45), fontSize: 11),
                ),
              ])),
            ]),

            if (item?.baseIp != null && item!.baseIp > 0) ...[
              const SizedBox(height: 14),
              Text('${item!.baseIp} IP', style: TextStyle(color: scheme.primary, fontSize: 13, fontWeight: FontWeight.bold)),
            ],

            // Stats
            if (item?.stats.isNotEmpty == true) ...[
              const SizedBox(height: 10),
              ...item!.stats.entries.map((s) => Text(
                '${s.key}: ${s.value}',
                style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
              )),
            ],

            // Recipe
            if (recipe != null && recipe.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('RECIPE', style: TextStyle(color: scheme.primary, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              ...(recipe.entries).map((r) {
                final ing = GameConfig.item(r.key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    '${ing?.icon ?? '📦'} ${ing?.name ?? r.key}  ×${r.value}',
                    style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.65), fontSize: 12),
                  ),
                );
              }),
            ],

            // Owned count
            const SizedBox(height: 14),
            Text('Owned: $qty', style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.4), fontSize: 11)),

            // Equip button
            if (item?.isEquippable == true) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final r = ref.read(inventoryProvider.notifier).equip(itemId);
                    Navigator.pop(context);
                    onFeedback(r);
                    onChanged();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Equip', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final tier = item?.tier ?? 0;

    return Tooltip(
      message: item?.name ?? itemId, // hover / long-press: name only
      preferBelow: false,
      child: GestureDetector(
        onTap: () => _showDetail(context, ref),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.15)),
          ),
          child: Stack(children: [
            // Prominent icon centred
            Center(child: Text(item?.icon ?? '📦', style: const TextStyle(fontSize: 26))),

            // Tier (roman) — top left
            if (tier > 0)
              Positioned(
                top: 4, left: 5,
                child: Text(
                  _toRoman(tier),
                  style: TextStyle(
                    color: scheme.primary.withValues(alpha: 0.7),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

            // Quantity — bottom right
            Positioned(
              bottom: 3, right: 5,
              child: Text(
                '$qty',
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.55),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Stats panel ───────────────────────────────────────────
class _StatsPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final playerState = ref.watch(playerProvider);
    final invState = ref.watch(inventoryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(playerState.characterName, style: TextStyle(color: scheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Total Item Power: ${invState.totalIP}', style: TextStyle(color: scheme.primary, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),

        _statSection('Combat', [
          ('⚔', 'Total IP', '${invState.totalIP}'),
          ('🛡', 'Gear Slots Filled', '${invState.gearSlots.values.where((v) => v != null).length}/6'),
        ]),
        const SizedBox(height: 16),

        _statSection('Progress', [
          ('👟', 'Step Bank', '${playerState.stepBank}'),
          ('⚡', 'Action Tokens', '${playerState.tokenBank}'),
          ('🪙', 'Gold', '${playerState.gold}'),
          ('⚔', 'Honour', '${playerState.honourPoints}'),
        ]),
        const SizedBox(height: 16),

        _statSection('Gear', [
          for (final e in invState.gearSlots.entries)
            (e.value != null ? GameConfig.item(e.value!)?.icon ?? '📦' : '○',
             e.key.toUpperCase(),
             e.value != null ? '${GameConfig.item(e.value!)?.name ?? e.value}  (${GameConfig.item(e.value!)?.baseIp ?? 0} IP)' : '—'),
        ]),
      ]),
    );
  }

  Widget _statSection(String title, List<(String, String, String)> rows) {
    return Builder(builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title.toUpperCase(), style: TextStyle(fontSize: 10, letterSpacing: 2, color: scheme.primary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...rows.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Text(r.$1, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Expanded(child: Text(r.$2, style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6), fontSize: 13))),
            Text(r.$3, style: TextStyle(color: scheme.onSurface, fontSize: 13, fontWeight: FontWeight.w500)),
          ]),
        )),
      ]);
    });
  }
}

// ── Shared ────────────────────────────────────────────────
class _TabChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? scheme.primary.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? scheme.primary.withValues(alpha: 0.5) : scheme.onSurface.withValues(alpha: 0.12)),
        ),
        child: Text(label, style: TextStyle(color: active ? scheme.primary : scheme.onSurface.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    );
  }
}