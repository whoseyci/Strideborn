import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/combat_config.dart';
import '../../config/game_config.dart';
import '../../state/providers/player_provider.dart';
import '../../state/providers/inventory_provider.dart';
import '../../state/providers/combat_settings_provider.dart';

// ════════════════════════════════════════════════════════
// MENU OVERLAY
// Three tabs: Crafting · Character · Combat
// The Combat tab lets the player configure auto-battle
// preferences — ability priority order and flee threshold.
// ════════════════════════════════════════════════════════

class MenuOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String)? onFeedback;
  const MenuOverlay({super.key, required this.onClose, this.onFeedback});

  @override
  State<MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<MenuOverlay>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: SafeArea(
        child: Column(children: [
          // ── Header ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              const Text('Menu',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: widget.onClose,
              )
            ]),
          ),
          TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: 'Crafting'),
              Tab(text: 'Character'),
              Tab(text: 'Combat'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _CraftingTab(),
                _CharacterTab(),
                _CombatTab(),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Crafting tab ───────────────────────────────────────────────────

class _CraftingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Crafting', style: TextStyle(color: Colors.white54)),
    );
  }
}

// ── Character tab ──────────────────────────────────────────────────

class _CharacterTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final invState = ref.watch(inventoryProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _statRow('Gold', '${playerState.gold} g'),
        _statRow('Step Bank', '${playerState.stepBank} steps'),
        const Divider(color: Colors.white24),
        const Text('Gear', style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        ...invState.gearSlots.entries.map((e) {
              final item = e.value != null ? GameConfig.item(e.value!) : null;
              return _statRow(
                  e.key[0].toUpperCase() + e.key.substring(1),
                  item?.name ?? '— empty —');
            }),
          ],
        );
  }

  Widget _statRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ]),
      );
}

// ── Combat tab ─────────────────────────────────────────────────────

class _CombatTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CombatTab> createState() => _CombatTabState();
}

class _CombatTabState extends ConsumerState<_CombatTab> {
  late CombatSettings _settings;
  late List<AbilityEntity> _playerAbilities;

  @override
  void initState() {
    super.initState();
    final cs = ref.read(combatSettingsProvider);
    // CHANGED: removed staminaFloor and useStepBankForCombat (stamina retired)
    _settings = CombatSettings(
      abilityPriority: List.from(cs.abilityPriority),
      fleeHpThreshold: cs.fleeHpThreshold,
    );
    _refreshAbilities();
  }

  void _refreshAbilities() {
    final invState = ref.read(inventoryProvider);
    final seen = <String>{};
    final abs  = <AbilityEntity>[];
    for (final itemId in invState.gearSlots.values.whereType<String>()) {
      final item = GameConfig.item(itemId);
      if (item?.abilities == null) continue;
      for (final id in item!.abilities!['active'] ?? []) {
        if (seen.add(id)) {
          final ab = GameConfig.ability(id);
          if (ab != null && !ab.isPassive) abs.add(ab);
        }
      }
    }
    _playerAbilities = abs;
    if (_settings.abilityPriority.isEmpty) {
      _settings.abilityPriority = abs.map((a) => a.id).toList();
    }
  }

  void _save() {
    ref.read(combatSettingsProvider.notifier).updateSettings(_settings);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Combat settings saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [

        // ── Ability priority ───────────────────────────────────
        const Text('Ability Priority',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Auto-combat tries abilities in this order',
            style: TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 8),

        if (_playerAbilities.isEmpty)
          const Text('No gear equipped with active abilities.',
              style: TextStyle(color: Colors.white38, fontSize: 12))
        else
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final id = _settings.abilityPriority.removeAt(oldIndex);
                _settings.abilityPriority.insert(newIndex, id);
              });
            },
            children: _settings.abilityPriority.map((id) {
              final ab = GameConfig.ability(id);
              if (ab == null) return const SizedBox.shrink(key: ValueKey('_'));
              return ListTile(
                key: ValueKey(id),
                leading: Text(ab.icon, style: const TextStyle(fontSize: 20)),
                title: Text(ab.name,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                // CHANGED: shows cooldown turns instead of stamina cost
                subtitle: Text(
                  ab.cooldownTurns == 0
                      ? 'No cooldown'
                      : '${ab.cooldownTurns} turn cooldown',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                trailing: const Icon(Icons.drag_handle, color: Colors.white24),
                dense: true,
              );
            }).toList(),
          ),

        const SizedBox(height: 24),
        const Divider(color: Colors.white12),

        // ── Auto-flee threshold ────────────────────────────────
        Row(children: [
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Auto-Flee HP',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('Flee when HP falls below this %',
                  style: TextStyle(color: Colors.white54, fontSize: 11)),
            ]),
          ),
          Text(
            _settings.fleeHpThreshold == 0
                ? 'OFF'
                : '${(_settings.fleeHpThreshold * 100).round()}%',
            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          ),
        ]),
        Slider(
          value: _settings.fleeHpThreshold,
          min: 0, max: 0.60, divisions: 6,
          label: _settings.fleeHpThreshold == 0
              ? 'OFF'
              : '${(_settings.fleeHpThreshold * 100).round()}%',
          onChanged: (v) => setState(() => _settings.fleeHpThreshold = v),
        ),

        const SizedBox(height: 32),

        // ── Save button ───────────────────────────────────────
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700),
          child: const Text('Save Settings'),
        ),
      ],
    );
  }
}