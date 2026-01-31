import 'package:kioske/data/database_helper.dart';
import 'package:kioske/models/order.dart';

/// Repository for Order data operations
class OrderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Get all orders
  Future<List<Order>> getAll({int? limit}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'orders',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map((map) => Order.fromMap(map)).toList();
  }

  /// Get orders by status
  Future<List<Order>> getByStatus(String status) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'orders',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Order.fromMap(map)).toList();
  }

  /// Get orders by customer
  Future<List<Order>> getByCustomer(String customerId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'orders',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Order.fromMap(map)).toList();
  }

  /// Get orders by cashier
  Future<List<Order>> getByCashier(String cashierId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'orders',
      where: 'cashier_id = ?',
      whereArgs: [cashierId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Order.fromMap(map)).toList();
  }

  /// Get orders by date range
  Future<List<Order>> getByDateRange(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'orders',
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Order.fromMap(map)).toList();
  }

  /// Get today's orders
  Future<List<Order>> getToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return getByDateRange(start, end);
  }

  /// Get order by ID
  Future<Order?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Order.fromMap(maps.first);
  }

  /// Create a new order
  Future<Order> create(Order order) async {
    final db = await _dbHelper.database;
    await db.insert('orders', order.toMap());
    return order;
  }

  /// Update an existing order
  Future<void> update(Order order) async {
    final db = await _dbHelper.database;
    await db.update(
      'orders',
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  /// Update order status
  Future<void> updateStatus(String orderId, String status) async {
    final db = await _dbHelper.database;
    final updates = <String, dynamic>{'status': status};
    if (status == 'completed') {
      updates['completed_at'] = DateTime.now().toIso8601String();
    }
    await db.update('orders', updates, where: 'id = ?', whereArgs: [orderId]);
  }

  /// Complete an order
  Future<void> completeOrder(String orderId) async {
    await updateStatus(orderId, 'completed');
  }

  /// Cancel an order
  Future<void> cancelOrder(String orderId) async {
    await updateStatus(orderId, 'cancelled');
  }

  /// Delete order permanently
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('orders', where: 'id = ?', whereArgs: [id]);
  }

  /// Get total sales for a date range
  Future<double> getTotalSales(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(total) as total 
      FROM orders 
      WHERE status = 'completed' 
        AND created_at >= ? 
        AND created_at <= ?
    ''',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get total mobile money sales for a date range
  Future<double> getMobileMoneySales(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(total) as total 
      FROM orders 
      WHERE status = 'completed' 
        AND payment_method IN ('om', 'momo')
        AND created_at >= ? 
        AND created_at <= ?
    ''',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get today's total sales
  Future<double> getTodaySales() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return getTotalSales(start, end);
  }

  /// Get order count for a date range
  Future<int> getOrderCount(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count 
      FROM orders 
      WHERE status = 'completed' 
        AND created_at >= ? 
        AND created_at <= ?
    ''',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return result.first['count'] as int;
  }

  /// Get today's order count
  Future<int> getTodayOrderCount() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return getOrderCount(start, end);
  }

  /// Get hourly sales breakdown
  Future<Map<int, double>> getHourlySales(DateTime date) async {
    final db = await _dbHelper.database;
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final orders = await getByDateRange(start, end);
    final hourlySales = <int, double>{};

    for (final order in orders) {
      if (order.status == 'completed') {
        final hour = order.createdAt.hour;
        hourlySales[hour] = (hourlySales[hour] ?? 0) + order.total;
      }
    }

    return hourlySales;
  }
}
