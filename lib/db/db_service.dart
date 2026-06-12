import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'save_data.dart';

class DbService {
  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [SaveDataSchema],
      directory: dir.path,
    );

    // Initialize the singleton save if it doesn't exist
    final existing = await isar.saveDatas.get(1);
    if (existing == null) {
      await isar.writeTxn(() async {
        await isar.saveDatas.put(SaveData()..id = 1);
      });
    }
  }

  static SaveData get save => isar.saveDatas.getSync(1) ?? SaveData();

  static Future<void> updateSave(void Function(SaveData save) update) async {
    final cur = isar.saveDatas.getSync(1) ?? SaveData();
    update(cur);
    cur.id = 1;
    await isar.writeTxn(() async {
      await isar.saveDatas.put(cur);
    });
  }
}
