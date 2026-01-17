import 'package:sqflite/sqflite.dart';
import 'package:kioske/data/database_helper.dart';
import 'package:kioske/models/customer.dart';

/// Repository for Customer data operations
class CustomerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Get all customers
  Future<List<Customer>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'customers',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Customer.fromMap(map)).toList();
  }

  /// Get customers by status
  Future<List<Customer>> getByStatus(String status) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'customers',
      where: 'status = ? AND is_active = ?',
      whereArgs: [status, 1],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Customer.fromMap(map)).toList();
  }

  /// Get customer by ID
  Future<Customer?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Customer.fromMap(maps.first);
  }

  /// Search customers
  Future<List<Customer>> search(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'customers',
      where: '(name LIKE ? OR phone LIKE ?) AND is_active = ?',
      whereArgs: ['%$query%', '%$query%', 1],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Customer.fromMap(map)).toList();
  }

  /// Create a new customer
  Future<Customer> create({
    required String name,
    String? phone,
    String? email,
    String? address,
  }) async {
    final db = await _dbHelper.database;
    final customer = Customer(
      id: DatabaseHelper.generateId(),
      name: name,
      phone: phone,
      email: email,
      address: address,
      createdAt: DateTime.now(),
    );
    await db.insert('customers', customer.toMap());
    return customer;
  }

  /// Update an existing customer
  Future<void> update(Customer customer) async {
    final db = await _dbHelper.database;
    final updatedCustomer = customer.copyWith(updatedAt: DateTime.now());
    await db.update(
      'customers',
      updatedCustomer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  /// Update customer purchase stats after an order
  Future<void> updatePurchaseStats(String customerId, double orderTotal) async {
    final db = await _dbHelper.database;
    final customer = await getById(customerId);
    if (customer == null) return;

    final newTotal = customer.totalPurchases + orderTotal;
    final newCount = customer.orderCount + 1;
    final newStatus = Customer.calculateStatus(newTotal, newCount);

    await db.update(
      'customers',
      {
        'total_purchases': newTotal,
        'order_count': newCount,
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [customerId],
    );
  }

  /// Deactivate customer (soft delete)
  Future<void> deactivate(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'customers',
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete customer permanently
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  /// Get customer count
  Future<int> getCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM customers WHERE is_active = 1',
    );
    return result.first['count'] as int;
  }

  /// Get VIP customers
  Future<List<Customer>> getVIPCustomers() async {
    return getByStatus('vip');
  }

  /// Get customer counts by date range (new vs returning)
  /// New customers: created within the date range
  /// Returning customers: created before the range but had orders in the range
  Future<Map<String, int>> getCustomerCountsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _dbHelper.database;

    // Count customers created in this period (new)
    final newResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count 
      FROM customers 
      WHERE is_active = 1 
        AND created_at >= ? 
        AND created_at <= ?
      ''',
      [start.toIso8601String(), end.toIso8601String()],
    );
    final newCount = newResult.first['count'] as int;

    // Count distinct customers with orders in this period who were created before
    final returningResult = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT c.id) as count 
      FROM customers c
      INNER JOIN orders o ON o.customer_id = c.id
      WHERE c.is_active = 1 
        AND c.created_at < ?
        AND o.created_at >= ? 
        AND o.created_at <= ?
        AND o.status = 'completed'
      ''',
      [start.toIso8601String(), start.toIso8601String(), end.toIso8601String()],
    );
    final returningCount = returningResult.first['count'] as int;

    return {'new': newCount, 'returning': returningCount};
  }
}
