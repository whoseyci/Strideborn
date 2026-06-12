import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/combat_config.dart';
import '../../db/db_service.dart';

class CombatSettingsNotifier extends Notifier<CombatSettings> {
  @override
  CombatSettings build() {
    final cur = DbService.save;
    final map = jsonDecode(cur.combatSettingsJson) as Map<String, dynamic>;
    if (map.isEmpty) return CombatSettings();
    return CombatSettings.fromJson(map);
  }

  Future<void> updateSettings(CombatSettings settings) async {
    state = settings;
    await DbService.updateSave((s) {
      s.combatSettingsJson = jsonEncode(state.toJson());
    });
  }
}

final combatSettingsProvider = NotifierProvider<CombatSettingsNotifier, CombatSettings>(() {
  return CombatSettingsNotifier();
});
