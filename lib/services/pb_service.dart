import 'package:pocketbase/pocketbase.dart';

// ─────────────────────────────────────────────────────────
// PocketBase Service
// Single source of truth for all DB operations.
// Replace the IP below when moving to Hetzner.
// ─────────────────────────────────────────────────────────

class PbService {
  static final PocketBase _pb = PocketBase('http://192.168.178.113:8090');
  static PocketBase get client => _pb;

  // ── Character ────────────────────────────────────────

  /// Load character by user id. Returns null if not found.
  static Future<Map<String, dynamic>?> loadCharacter(String userId) async {
    try {
      final result = await _pb.collection('characters').getList(
        filter: 'user_id = "$userId"',
        perPage: 1,
      );
      if (result.items.isEmpty) return null;
      return result.items.first.toJson();
    } catch (e) {
      return null;
    }
  }

  /// Create a new character record.
  static Future<Map<String, dynamic>?> createCharacter({
    required String userId,
    required String username,
  }) async {
    try {
      final record = await _pb.collection('characters').create(body: {
        'user_id': userId,
        'username': username,
        'step_bank': 0,
        'token_bank': 0,
        'gold': 0,
        'honour_points': 0,
        'current_location_type': 'city',
        'current_location_id': 'ironhaven',
        'travel_destination_id': '',
        'travel_steps_remaining': 0,
        'active_activity_id': '',
        'last_step_count': 0,  // used for HealthKit delta
        'lifetime_steps': 0,
      });
      return record.toJson();
    } catch (e) {
      return null;
    }
  }

  /// Save full character state.
  static Future<void> saveCharacter(String recordId, Map<String, dynamic> data) async {
    try {
      await _pb.collection('characters').update(recordId, body: data);
    } catch (_) {}
  }

  // ── Inventory ────────────────────────────────────────

  /// Load all inventory rows for a character.
  static Future<List<Map<String, dynamic>>> loadInventory(String characterId) async {
    try {
      final result = await _pb.collection('inventory').getList(
        filter: 'character_id = "$characterId"',
        perPage: 200,
      );
      // Normalise: support both old item_name and new item_id field
      return result.items.map((r) {
        final data = r.toJson();
        if (!data.containsKey('item_id') && data.containsKey('item_name')) {
          data['item_id'] = data['item_name'];
        }
        return data;
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Upsert an inventory item (create or update by item_id).
  static Future<void> upsertInventoryItem({
    required String characterId,
    required String itemId,
    required int quantity,
  }) async {
    try {
      final existing = await _pb.collection('inventory').getList(
        filter: 'character_id = "$characterId" && item_id = "$itemId"',
        perPage: 1,
      );
      if (existing.items.isEmpty) {
        if (quantity > 0) {
          await _pb.collection('inventory').create(body: {
            'character_id': characterId,
            'item_id': itemId,
            'quantity': quantity,
          });
        }
      } else {
        final id = existing.items.first.id;
        if (quantity <= 0) {
          await _pb.collection('inventory').delete(id);
        } else {
          await _pb.collection('inventory').update(id, body: {'quantity': quantity});
        }
      }
    } catch (_) {}
  }

  // ── Config overrides ────────────────────────────────

  /// Fetch live config overrides from PocketBase.
  /// Returns empty list if collection doesn't exist yet.
  static Future<List<Map<String, dynamic>>> fetchConfigOverrides() async {
    try {
      final result = await _pb.collection('game_config_overrides').getList(perPage: 500);
      return result.items.map((r) => r.toJson()).toList();
    } catch (_) {
      return [];
    }
  }


  /// Load all gear slots for a character.
  static Future<Map<String, String?>> loadGearSlots(String characterId) async {
    final defaults = <String, String?>{
      'weapon': null, 'helmet': null, 'chest': null,
      'legs': null, 'boots': null, 'offhand': null,
    };
    try {
      final result = await _pb.collection('gear_slots').getList(
        filter: 'character_id = "$characterId"',
        perPage: 10,
      );
      for (final r in result.items) {
        final slot = r.data['slot'] as String?;
        final itemId = r.data['item_id'] as String?;
        if (slot != null) defaults[slot] = (itemId?.isEmpty ?? true) ? null : itemId;
      }
      return defaults;
    } catch (_) {
      return defaults;
    }
  }

  /// Upsert a gear slot.
  static Future<void> saveGearSlot({
    required String characterId,
    required String slot,
    required String? itemId,
  }) async {
    try {
      final existing = await _pb.collection('gear_slots').getList(
        filter: 'character_id = "$characterId" && slot = "$slot"',
        perPage: 1,
      );
      if (existing.items.isEmpty) {
        await _pb.collection('gear_slots').create(body: {
          'character_id': characterId,
          'slot': slot,
          'item_id': itemId ?? '',
        });
      } else {
        await _pb.collection('gear_slots').update(
          existing.items.first.id,
          body: {'item_id': itemId ?? ''},
        );
      }
    } catch (_) {}
  }
}


