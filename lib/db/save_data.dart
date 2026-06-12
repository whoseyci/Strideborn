import 'dart:convert';
import 'package:isar/isar.dart';

part 'save_data.g.dart';

@collection
class SaveData {
  Id id = 1; // Singleton save ID

  // Player Stats
  int stepBank = 0;
  int gold = 0;
  int tokenBank = 0;
  int honourPoints = 0;
  String characterName = 'Adventurer';

  // Navigation
  String currentLocationId = 'millhaven_fields';
  String? travelDestinationId;
  int travelStepsRemaining = 0;
  List<String> enabledGatherIds = [];
  bool combatEnabled = true;

  // Since Isar doesn't natively support Maps, we can store JSON strings for dynamic lists/maps
  // Maps to Map<String, int>
  String inventoryJson = '{}';
  
  // Maps to Map<String, String?>
  String gearSlotsJson = '{}';

  // Maps to ActiveNode
  String? currentNodeJson;

  // Maps to CombatSettings
  String combatSettingsJson = '{}';

  // Legacy Activity
  List<String> activeActivityIds = [];
  String? walkToCraftActivityId;
  int walkProgress = 0;
}
