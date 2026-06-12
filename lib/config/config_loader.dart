import 'dart:convert';
import 'package:flutter/services.dart';
import 'game_config.dart';
import 'combat_config.dart';
import '../map/map_generator.dart';

// ════════════════════════════════════════════════════════
// CONFIG LOADER
// Loads all JSON assets at startup and populates GameConfig.
// To add new content: drop a JSON file, add one loadX() call here.
// ════════════════════════════════════════════════════════

class ConfigLoader {
  /// Call once during app startup (in main.dart before runApp).
  static Future<void> loadBundled() async {
    await Future.wait([
      _loadLocations(),
      _loadActivities(),
      _loadStations(),
      _loadItems(),
      _loadAbilities(),
      _loadMonsters(),
      _loadZoneNodes(),
    ]);

    // ── Generate 11x11 Map Matrix ─────────────────────────────────
    MapGenerator.generate();
    for (final loc in MapGenerator.generatedLocations.values) {
      GameConfig.registerLocation(loc);
    }
    for (final node in MapGenerator.generatedZoneNodes.values) {
      GameConfig.registerZoneNodes(node);
    }
  }

  // ── Core game data ────────────────────────────────────────────

  static Future<void> _loadLocations() async {
    final data = await _loadJson('assets/config/locations.json');
    final list = data['locations'] as List? ?? [];
    for (final j in list) {
      GameConfig.registerLocation(
          LocationEntity.fromJson(j as Map<String, dynamic>));
    }
  }

  static Future<void> _loadActivities() async {
    final data = await _loadJson('assets/config/activities.json');
    final list = data['activities'] as List? ?? [];
    for (final j in list) {
      GameConfig.registerActivity(
          ActivityEntity.fromJson(j as Map<String, dynamic>));
    }
  }

  static Future<void> _loadStations() async {
    final data = await _loadJson('assets/config/stations.json');
    final list = data['stations'] as List? ?? [];
    for (final j in list) {
      GameConfig.registerStation(
          StationEntity.fromJson(j as Map<String, dynamic>));
    }
  }

  static Future<void> _loadItems() async {
    final data = await _loadJson('assets/config/items.json');
    final list = data['items'] as List? ?? [];
    for (final j in list) {
      GameConfig.registerItem(
          ItemEntity.fromJson(j as Map<String, dynamic>));
    }
  }

  // ── Combat data ───────────────────────────────────────────────

  /// abilities.json: { "abilities": { "id": {...}, ... } }
  static Future<void> _loadAbilities() async {
    final data = await _loadJson('assets/config/abilities.json');
    final map  = data['abilities'] as Map<String, dynamic>? ?? {};
    for (final entry in map.entries) {
      GameConfig.registerAbility(
          AbilityEntity.fromJson(entry.key, entry.value as Map<String, dynamic>));
    }
  }

  /// monsters.json: { "monsters": [ {...}, ... ] }
  static Future<void> _loadMonsters() async {
    final data = await _loadJson('assets/config/monsters.json');
    final list = data['monsters'] as List? ?? [];
    for (final j in list) {
      GameConfig.registerMonster(
          MonsterTemplate.fromJson(j as Map<String, dynamic>));
    }
  }

  /// zone_nodes.json: { "zones": [ {...}, ... ] }
  static Future<void> _loadZoneNodes() async {
    final data = await _loadJson('assets/config/zone_nodes.json');
    final list = data['zones'] as List? ?? [];
    for (final j in list) {
      GameConfig.registerZoneNodes(
          ZoneNodeConfig.fromJson(j as Map<String, dynamic>));
    }
  }

  // ── PocketBase override (optional, called after loadBundled) ──

  /// Override bundled config with server-side values.
  /// Pass in the raw JSON maps fetched from PocketBase.
  static void applyServerOverrides({
    List<Map<String, dynamic>>? abilities,
    List<Map<String, dynamic>>? monsters,
    List<Map<String, dynamic>>? zoneNodes,
    List<Map<String, dynamic>>? items,
  }) {
    if (abilities != null) {
      for (final j in abilities) {
        GameConfig.registerAbility(AbilityEntity.fromJson(
            j['id'] as String, j['data'] as Map<String, dynamic>));
      }
    }
    if (monsters != null) {
      for (final j in monsters) {
        GameConfig.registerMonster(MonsterTemplate.fromJson(j));
      }
    }
    if (zoneNodes != null) {
      for (final j in zoneNodes) {
        GameConfig.registerZoneNodes(ZoneNodeConfig.fromJson(j));
      }
    }
    if (items != null) {
      for (final j in items) {
        GameConfig.registerItem(ItemEntity.fromJson(j));
      }
    }
  }

  /// Background fetch of PocketBase config overrides.
  /// No-op if PocketBase is unreachable — bundled config remains in effect.
  static Future<void> fetchOverrides() async {
    // Wire to PbService.fetchConfigOverrides() + applyServerOverrides() when ready.
  }

  // ── Utility ───────────────────────────────────────────────────

  static Future<Map<String, dynamic>> _loadJson(String assetPath) async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      // Return empty map if file missing — loader is fault-tolerant
      return {};
    }
  }
}