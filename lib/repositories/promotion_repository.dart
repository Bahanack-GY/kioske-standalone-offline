import 'package:kioske/data/database_helper.dart';
import 'package:kioske/models/promotion.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class PromotionRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<Promotion>> getAll() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'promotions',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Promotion.fromMap(maps[i]));
  }

  Future<Promotion?> getById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'promotions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Promotion.fromMap(maps.first);
    }
    return null;
  }

  Future<Promotion> create({
    required String title,
    String? description,
    required String type,
    required double value,
    double? minimumPurchase,
    String? productId,
    String? categoryId,
    required DateTime startDate,
    required DateTime endDate,
    bool isActive = true,
  }) async {
    final db = await _databaseHelper.database;
    final promotion = Promotion(
      id: const Uuid().v4(),
      title: title,
      description: description,
      type: type,
      value: value,
      minimumPurchase: minimumPurchase,
      productId: productId,
      categoryId: categoryId,
      isActive: isActive,
      startDate: startDate,
      endDate: endDate,
      createdAt: DateTime.now(),
    );

    await db.insert(
      'promotions',
      promotion.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return promotion;
  }

  Future<void> update(Promotion promotion) async {
    final db = await _databaseHelper.database;
    await db.update(
      'promotions',
      promotion.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [promotion.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _databaseHelper.database;
    await db.delete('promotions', where: 'id = ?', whereArgs: [id]);
  }
}
