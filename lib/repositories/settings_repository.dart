import 'package:sqflite/sqflite.dart';
import 'package:kioske/data/database_helper.dart';
import 'package:kioske/models/settings.dart';

class SettingsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Get all settings
  Future<List<AppSettings>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('settings');
    return List.generate(maps.length, (i) => AppSettings.fromMap(maps[i]));
  }

  /// Get setting by key
  Future<AppSettings?> getByKey(String key) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isNotEmpty) {
      return AppSettings.fromMap(maps.first);
    }
    return null;
  }

  /// Create or Update setting
  Future<void> save(AppSettings setting) async {
    final db = await _dbHelper.database;
    await db.insert(
      'settings',
      setting.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Create or Update multiple settings
  Future<void> saveAll(List<AppSettings> settings) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final setting in settings) {
      batch.insert(
        'settings',
        setting.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Get Business Settings object
  Future<BusinessSettings> getBusinessSettings() async {
    final settingsList = await getAll();
    return BusinessSettings.fromSettingsList(settingsList);
  }
}
