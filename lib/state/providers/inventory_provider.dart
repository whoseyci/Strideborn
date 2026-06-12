import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/game_config.dart';
import '../../db/db_service.dart';

class InventoryState {
  final Map<String, int> inventory;
  final Map<String, String?> gearSlots;

  const InventoryState({required this.inventory, required this.gearSlots});

  InventoryState copyWith({
    Map<String, int>? inventory,
    Map<String, String?>? gearSlots,
  }) {
    return InventoryState(
      inventory: inventory ?? this.inventory,
      gearSlots: gearSlots ?? this.gearSlots,
    );
  }

  int get totalIP => gearSlots.values
      .whereType<String>()
      .map((id) => GameConfig.item(id)?.baseIp ?? 0)
      .fold(0, (a, b) => a + b);

  List<ItemEntity> get equippableInInventory => inventory.keys
      .map((id) => GameConfig.item(id))
      .whereType<ItemEntity>()
      .where((item) => item.isEquippable && (inventory[item.id] ?? 0) > 0)
      .toList();
}

class InventoryNotifier extends Notifier<InventoryState> {
  @override
  InventoryState build() {
    final cur = DbService.save;
    final invMap = Map<String, dynamic>.from(jsonDecode(cur.inventoryJson));
    final gearMap = Map<String, dynamic>.from(jsonDecode(cur.gearSlotsJson));
    
    return InventoryState(
      inventory: invMap.map((k, v) => MapEntry(k, (v as num).toInt())),
      gearSlots: {
        'weapon': gearMap['weapon'] as String?,
        'helmet': gearMap['helmet'] as String?,
        'chest': gearMap['chest'] as String?,
        'legs': gearMap['legs'] as String?,
        'offhand': gearMap['offhand'] as String?,
        'cape': gearMap['cape'] as String?,
      },
    );
  }

  Future<void> _save() async {
    await DbService.updateSave((s) {
      s.inventoryJson = jsonEncode(state.inventory);
      s.gearSlotsJson = jsonEncode(state.gearSlots);
    });
  }

  String equip(String itemId) {
    final item = GameConfig.item(itemId);
    if (item == null || item.gearSlot == null) return '⚠ Cannot equip.';
    final slot = item.gearSlot!;
    
    final newInv = Map<String, int>.from(state.inventory);
    final newGear = Map<String, String?>.from(state.gearSlots);
    
    final current = newGear[slot];
    if (current != null) {
      newInv[current] = (newInv[current] ?? 0) + 1;
    }
    
    final qty = newInv[itemId] ?? 0;
    if (qty <= 0) return '⚠ Not in inventory.';
    
    newInv[itemId] = qty - 1;
    if (newInv[itemId] == 0) newInv.remove(itemId);
    
    newGear[slot] = itemId;
    state = state.copyWith(inventory: newInv, gearSlots: newGear);
    _save();
    return '✓ Equipped ${item.name}.';
  }

  String unequip(String slot) {
    final newGear = Map<String, String?>.from(state.gearSlots);
    final itemId = newGear[slot];
    if (itemId == null) return '⚠ Nothing in $slot.';
    
    newGear[slot] = null;
    final newInv = Map<String, int>.from(state.inventory);
    newInv[itemId] = (newInv[itemId] ?? 0) + 1;
    
    state = state.copyWith(inventory: newInv, gearSlots: newGear);
    _save();
    return '✓ Unequipped ${GameConfig.item(itemId)?.name ?? itemId}.';
  }

  void upsertInventoryItem(String itemId, int delta) {
    final newInv = Map<String, int>.from(state.inventory);
    final next = ((newInv[itemId] ?? 0) + delta).clamp(0, 99999);
    if (next == 0) {
      newInv.remove(itemId);
    } else {
      newInv[itemId] = next;
    }
    state = state.copyWith(inventory: newInv);
    _save();
  }
}

final inventoryProvider = NotifierProvider<InventoryNotifier, InventoryState>(() {
  return InventoryNotifier();
});
