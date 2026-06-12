import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'save_data.dart';

/// Web storage backend — SharedPreferences (localStorage).
///
/// Isar 3.x has no working web support, so on web the singleton SaveData
/// is serialized to JSON in localStorage. Same public API as the native
/// DbService; an in-memory copy keeps `save` synchronous like Isar's
/// getSync, with writes flushed asynchronously.
class DbService {
  static const _key = 'strideborn.save.v1';
  static late SharedPreferences _prefs;
  static SaveData _cache = SaveData();

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getString(_key);
    if (raw != null) {
      try {
        _cache = _fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        _cache = SaveData()..id = 1;
      }
    } else {
      _cache = SaveData()..id = 1;
      await _flush();
    }
  }

  static SaveData get save => _cache;

  static Future<void> updateSave(void Function(SaveData save) update) async {
    update(_cache);
    _cache.id = 1;
    await _flush();
  }

  static Future<void> _flush() =>
      _prefs.setString(_key, jsonEncode(_toJson(_cache)));

  static Map<String, dynamic> _toJson(SaveData s) => {
        'stepBank': s.stepBank,
        'gold': s.gold,
        'tokenBank': s.tokenBank,
        'honourPoints': s.honourPoints,
        'characterName': s.characterName,
        'currentLocationId': s.currentLocationId,
        'travelDestinationId': s.travelDestinationId,
        'travelStepsRemaining': s.travelStepsRemaining,
        'enabledGatherIds': s.enabledGatherIds,
        'combatEnabled': s.combatEnabled,
        'inventoryJson': s.inventoryJson,
        'gearSlotsJson': s.gearSlotsJson,
        'currentNodeJson': s.currentNodeJson,
        'combatSettingsJson': s.combatSettingsJson,
        'activeActivityIds': s.activeActivityIds,
        'walkToCraftActivityId': s.walkToCraftActivityId,
        'walkProgress': s.walkProgress,
      };

  static SaveData _fromJson(Map<String, dynamic> j) => SaveData()
    ..id = 1
    ..stepBank = (j['stepBank'] as num?)?.toInt() ?? 0
    ..gold = (j['gold'] as num?)?.toInt() ?? 0
    ..tokenBank = (j['tokenBank'] as num?)?.toInt() ?? 0
    ..honourPoints = (j['honourPoints'] as num?)?.toInt() ?? 0
    ..characterName = j['characterName'] as String? ?? 'Adventurer'
    ..currentLocationId =
        j['currentLocationId'] as String? ?? 'millhaven_fields'
    ..travelDestinationId = j['travelDestinationId'] as String?
    ..travelStepsRemaining = (j['travelStepsRemaining'] as num?)?.toInt() ?? 0
    ..enabledGatherIds =
        (j['enabledGatherIds'] as List?)?.cast<String>() ?? []
    ..combatEnabled = j['combatEnabled'] as bool? ?? true
    ..inventoryJson = j['inventoryJson'] as String? ?? '{}'
    ..gearSlotsJson = j['gearSlotsJson'] as String? ?? '{}'
    ..currentNodeJson = j['currentNodeJson'] as String?
    ..combatSettingsJson = j['combatSettingsJson'] as String? ?? '{}'
    ..activeActivityIds =
        (j['activeActivityIds'] as List?)?.cast<String>() ?? []
    ..walkToCraftActivityId = j['walkToCraftActivityId'] as String?
    ..walkProgress = (j['walkProgress'] as num?)?.toInt() ?? 0;
}
