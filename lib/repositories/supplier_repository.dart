import 'package:sqflite/sqflite.dart';
import 'package:kioske/data/database_helper.dart';
import 'package:kioske/models/supplier.dart';
import 'package:kioske/models/supplier_stats.dart';

/// Repository for Supplier data operations
class SupplierRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Get all suppliers
  Future<List<Supplier>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'suppliers',
      where: 'status != ?',
      whereArgs: ['blacklisted'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Supplier.fromMap(map)).toList();
  }

  /// Get all suppliers with calculated statistics
  Future<List<SupplierStats>> getAllWithStats() async {
    final db = await _dbHelper.database;

    // 1. Get all suppliers
    final suppliersMaps = await db.query(
      'suppliers',
      where: 'status != ?',
      whereArgs: ['blacklisted'],
      orderBy: 'name ASC',
    );
    final suppliers = suppliersMaps
        .map((map) => Supplier.fromMap(map))
        .toList();

    final List<SupplierStats> stats = [];

    for (final supplier in suppliers) {
      // 2. Get Aggregates from supply_deliveries
      final aggResult = await db.rawQuery(
        '''
        SELECT 
          COUNT(id) as delivery_count,
          SUM(total_amount) as total_amount,
          SUM(item_count) as total_items
        FROM supply_deliveries
        WHERE supplier_id = ? AND status = 'completed'
      ''',
        [supplier.id],
      );

      final deliveryCount = aggResult.first['delivery_count'] as int? ?? 0;
      final totalAmount =
          (aggResult.first['total_amount'] as num?)?.toDouble() ?? 0.0;
      final totalItems = aggResult.first['total_items'] as int? ?? 0;

      // 3. Get distinct top products
      // We join supply_deliveries -> supply_delivery_items -> products (implied by name in items)
      // Actually item stores product_name redundantly? Let's check model.
      // Yes, supply_delivery_items usually stores product_name or we join.
      // Let's assume we can get names from supply_delivery_items joined with supply_deliveries.
      final productsResult = await db.rawQuery(
        '''
        SELECT DISTINCT i.product_name
        FROM supply_delivery_items i
        JOIN supply_deliveries d ON i.delivery_id = d.id
        WHERE d.supplier_id = ? AND d.status = 'completed'
        LIMIT 10
      ''',
        [supplier.id],
      );

      final productNames = productsResult
          .map((row) => row['product_name'] as String)
          .toList();

      final topProducts = productNames.take(3).toList();
      final otherCount = productNames.length > 3 ? productNames.length - 3 : 0;

      stats.add(
        SupplierStats(
          supplier: supplier,
          totalDeliveries: deliveryCount,
          totalAmount: totalAmount,
          totalItemsSupplied: totalItems,
          productNames: topProducts,
          otherProductsCount: otherCount,
        ),
      );
    }

    return stats;
  }

  /// Get suppliers by status
  Future<List<Supplier>> getByStatus(String status) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'suppliers',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Supplier.fromMap(map)).toList();
  }

  /// Get supplier by ID
  Future<Supplier?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'suppliers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Supplier.fromMap(maps.first);
  }

  /// Search suppliers
  Future<List<Supplier>> search(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'suppliers',
      where: 'name LIKE ? AND status != ?',
      whereArgs: ['%$query%', 'blacklisted'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Supplier.fromMap(map)).toList();
  }

  /// Create a new supplier
  Future<Supplier> create({
    required String name,
    String? phone,
    String? email,
    String? address,
    String? contactPerson,
  }) async {
    final db = await _dbHelper.database;
    final supplier = Supplier(
      id: DatabaseHelper.generateId(),
      name: name,
      phone: phone,
      email: email,
      address: address,
      contactPerson: contactPerson,
      createdAt: DateTime.now(),
    );
    await db.insert('suppliers', supplier.toMap());
    return supplier;
  }

  /// Update an existing supplier
  Future<void> update(Supplier supplier) async {
    final db = await _dbHelper.database;
    final updatedSupplier = supplier.copyWith(updatedAt: DateTime.now());
    await db.update(
      'suppliers',
      updatedSupplier.toMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
  }

  /// Update supplier order stats
  Future<void> updateOrderStats(String supplierId, double orderAmount) async {
    final db = await _dbHelper.database;
    final supplier = await getById(supplierId);
    if (supplier == null) return;

    await db.update(
      'suppliers',
      {
        'total_orders': supplier.totalOrders + orderAmount,
        'order_count': supplier.orderCount + 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [supplierId],
    );
  }

  /// Update supplier status
  Future<void> updateStatus(String supplierId, String status) async {
    final db = await _dbHelper.database;
    await db.update(
      'suppliers',
      {'status': status, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [supplierId],
    );
  }

  /// Delete supplier permanently
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('suppliers', where: 'id = ?', whereArgs: [id]);
  }

  /// Get supplier count
  Future<int> getCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM suppliers WHERE status = 'active'",
    );
    return result.first['count'] as int;
  }
}
