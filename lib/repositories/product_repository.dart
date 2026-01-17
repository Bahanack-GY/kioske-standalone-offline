import 'package:sqflite/sqflite.dart';
import 'package:kioske/data/database_helper.dart';
import 'package:kioske/models/product.dart';

/// Repository for Product data operations
class ProductRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Get all products
  Future<List<Product>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'products',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  /// Get products by category
  Future<List<Product>> getByCategory(String categoryId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'products',
      where: 'category_id = ? AND is_active = ?',
      whereArgs: [categoryId, 1],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  /// Get product by ID
  Future<Product?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  /// Search products by name
  Future<List<Product>> search(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'products',
      where: 'name LIKE ? AND is_active = ?',
      whereArgs: ['%$query%', 1],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  /// Get products with low stock
  Future<List<Product>> getLowStock({int threshold = 10}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'products',
      where: 'stock <= ? AND is_active = ?',
      whereArgs: [threshold, 1],
      orderBy: 'stock ASC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  /// Create a new product
  Future<Product> create({
    required String name,
    required String categoryId,
    required double purchasePrice,
    required double salePrice,
    required int stock,
    String? imageUrl,
  }) async {
    final db = await _dbHelper.database;
    final status = Product.calculateStatus(stock);
    final product = Product(
      id: DatabaseHelper.generateId(),
      name: name,
      categoryId: categoryId,
      purchasePrice: purchasePrice,
      salePrice: salePrice,
      stock: stock,
      imageUrl: imageUrl,
      status: status,
      isActive: true,
      createdAt: DateTime.now(),
    );
    await db.insert('products', product.toMap());
    return product;
  }

  /// Update an existing product
  Future<void> update(Product product) async {
    final db = await _dbHelper.database;
    // Recalculate status based on stock
    final status = Product.calculateStatus(product.stock);
    final updatedProduct = product.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    await db.update(
      'products',
      updatedProduct.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  /// Update product stock
  Future<void> updateStock(String productId, int newStock) async {
    final db = await _dbHelper.database;
    final status = Product.calculateStatus(newStock);
    await db.update(
      'products',
      {
        'stock': newStock,
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  /// Decrease stock (for sales)
  Future<bool> decreaseStock(
    String productId,
    int quantity, {
    required String userId,
    String? reason,
    String? orderId,
  }) async {
    final db = await _dbHelper.database;
    final product = await getById(productId);
    if (product == null || product.stock < quantity) {
      return false;
    }
    final previousStock = product.stock;
    final newStock = product.stock - quantity;
    await updateStock(productId, newStock);

    // Log stock movement
    await db.insert('stock_movements', {
      'id': DatabaseHelper.generateId(),
      'product_id': productId,
      'type': 'out',
      'quantity': quantity,
      'previous_stock': previousStock,
      'new_stock': newStock,
      'order_id': orderId,
      'reason': reason ?? 'Sale',
      'created_by': userId,
      'created_at': DateTime.now().toIso8601String(),
    });

    return true;
  }

  /// Increase stock (for restocking)
  Future<void> increaseStock(
    String productId,
    int quantity, {
    required String userId,
    String? reason,
    String? supplierId,
  }) async {
    final db = await _dbHelper.database;
    final product = await getById(productId);
    if (product == null) return;

    final previousStock = product.stock;
    final newStock = product.stock + quantity;
    await updateStock(productId, newStock);

    // Log stock movement
    await db.insert('stock_movements', {
      'id': DatabaseHelper.generateId(),
      'product_id': productId,
      'type': 'in',
      'quantity': quantity,
      'previous_stock': previousStock,
      'new_stock': newStock,
      'supplier_id': supplierId,
      'reason': reason ?? 'Restock',
      'created_by': userId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Deactivate product (soft delete)
  Future<void> deactivate(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'products',
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete product permanently
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  /// Get total product count
  Future<int> getCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM products WHERE is_active = 1',
    );
    return result.first['count'] as int;
  }

  /// Get total stock value
  Future<double> getTotalStockValue() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(stock * purchase_price) as total FROM products WHERE is_active = 1',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
