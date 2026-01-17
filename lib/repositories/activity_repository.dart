import 'package:kioske/data/database_helper.dart';
import 'package:kioske/models/activity.dart';

/// Repository for Activity data operations
class ActivityRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Get all activities with pagination
  Future<List<Activity>> getAll({int limit = 15, int offset = 0}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'activities',
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((map) => Activity.fromMap(map)).toList();
  }

  /// Get total activity count
  Future<int> getCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM activities',
    );
    return result.first['count'] as int;
  }

  /// Create a new activity log
  Future<Activity> create(Activity activity) async {
    final db = await _dbHelper.database;
    await db.insert('activities', activity.toMap());
    return activity;
  }

  /// Get activities by user
  Future<List<Activity>> getByUser(
    String userId, {
    int limit = 15,
    int offset = 0,
  }) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'activities',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((map) => Activity.fromMap(map)).toList();
  }

  /// Get last activity by user and action
  Future<Activity?> getLastUserAction(String userId, String action) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'activities',
      where: 'user_id = ? AND action = ?',
      whereArgs: [userId, action],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Activity.fromMap(maps.first);
  }
}
