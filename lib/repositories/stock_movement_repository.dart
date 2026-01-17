import 'package:kioske/data/database_helper.dart';
import 'package:kioske/models/stock_movement.dart';

/// Repository for StockMovement data operations
class StockMovementRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Get all movements for a product
  Future<List<StockMovement>> getByProduct(String productId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'stock_movements',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => StockMovement.fromMap(map)).toList();
  }

  /// Get movements by date range
  Future<List<StockMovement>> getByDateRange(
    DateTime start,
    DateTime end, {
    String? productId,
  }) async {
    final db = await _dbHelper.database;
    String where = 'created_at >= ? AND created_at <= ?';
    List<dynamic> whereArgs = [start.toIso8601String(), end.toIso8601String()];

    if (productId != null) {
      where += ' AND product_id = ?';
      whereArgs.add(productId);
    }

    final maps = await db.query(
      'stock_movements',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => StockMovement.fromMap(map)).toList();
  }

  /// Get recent movements (last 30 days)
  Future<List<StockMovement>> getRecent({int days = 30}) async {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    return getByDateRange(start, end);
  }

  /// Create a stock movement record
  Future<StockMovement> create({
    required String productId,
    required String type,
    required int quantity,
    required int previousStock,
    required int newStock,
    String? supplierId,
    String? orderId,
    String? reason,
    String? notes,
    required String createdBy,
  }) async {
    final db = await _dbHelper.database;
    final movement = StockMovement(
      id: DatabaseHelper.generateId(),
      productId: productId,
      type: type,
      quantity: quantity,
      previousStock: previousStock,
      newStock: newStock,
      supplierId: supplierId,
      orderId: orderId,
      reason: reason,
      notes: notes,
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );
    await db.insert('stock_movements', movement.toMap());
    return movement;
  }

  /// Get stock history aggregated by day for charts
  Future<Map<DateTime, int>> getStockHistoryByDay(
    String productId, {
    int days = 30,
  }) async {
    final movements = await getByDateRange(
      DateTime.now().subtract(Duration(days: days)),
      DateTime.now(),
      productId: productId,
    );

    final history = <DateTime, int>{};
    for (final movement in movements) {
      final date = DateTime(
        movement.createdAt.year,
        movement.createdAt.month,
        movement.createdAt.day,
      );
      // Use the latest newStock value for each day
      history[date] = movement.newStock;
    }
    return history;
  }

  /// Get total inbound quantity for a product in date range
  Future<int> getTotalInbound(
    String productId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(quantity), 0) as total 
      FROM stock_movements 
      WHERE product_id = ? 
        AND type = 'in'
        AND created_at >= ? 
        AND created_at <= ?
      ''',
      [productId, start.toIso8601String(), end.toIso8601String()],
    );
    return result.first['total'] as int;
  }

  /// Get total outbound quantity for a product in date range
  Future<int> getTotalOutbound(
    String productId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(quantity), 0) as total 
      FROM stock_movements 
      WHERE product_id = ? 
        AND type = 'out'
        AND created_at >= ? 
        AND created_at <= ?
      ''',
      [productId, start.toIso8601String(), end.toIso8601String()],
    );
    return result.first['total'] as int;
  }

  /// Get all movements
  Future<List<StockMovement>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('stock_movements', orderBy: 'created_at DESC');
    return maps.map((map) => StockMovement.fromMap(map)).toList();
  }
}
