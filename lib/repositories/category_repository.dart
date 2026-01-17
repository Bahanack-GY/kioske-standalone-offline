import 'package:sqflite/sqflite.dart';
import 'package:kioske/data/database_helper.dart';
import 'package:kioske/models/category.dart';

/// Repository for Category data operations
class CategoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Get all categories
  Future<List<Category>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'sort_order ASC',
    );
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  /// Get category by ID
  Future<Category?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  /// Create a new category
  Future<Category> create({
    required String name,
    String? icon,
    int sortOrder = 0,
  }) async {
    final db = await _dbHelper.database;
    final category = Category(
      id: DatabaseHelper.generateId(),
      name: name,
      icon: icon,
      sortOrder: sortOrder,
      isActive: true,
      createdAt: DateTime.now(),
    );
    await db.insert('categories', category.toMap());
    return category;
  }

  /// Update an existing category
  Future<void> update(Category category) async {
    final db = await _dbHelper.database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Deactivate category (soft delete)
  Future<void> deactivate(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'categories',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete category permanently
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  /// Get product count per category
  Future<Map<String, int>> getProductCounts() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT category_id, COUNT(*) as count 
      FROM products 
      WHERE is_active = 1 
      GROUP BY category_id
    ''');

    final counts = <String, int>{};
    for (final row in result) {
      counts[row['category_id'] as String] = row['count'] as int;
    }
    return counts;
  }
}
