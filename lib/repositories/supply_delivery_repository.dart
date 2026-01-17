import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:kioske/data/database_helper.dart';
import 'package:kioske/models/supply_delivery.dart';
import 'package:kioske/models/supply_delivery_item.dart';

class SupplyDeliveryRepository {
  final _uuid = const Uuid();

  Future<Database> get _db async => await DatabaseHelper.instance.database;

  /// Get all supply deliveries ordered by creation date descending
  Future<List<SupplyDelivery>> getAll() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        d.*,
        s.name as supplier_name
      FROM supply_deliveries d
      LEFT JOIN suppliers s ON d.supplier_id = s.id
      ORDER BY d.created_at DESC
    ''');

    return maps.map((map) => SupplyDelivery.fromMap(map)).toList();
  }

  /// Get deliveries filtered by status
  Future<List<SupplyDelivery>> getByStatus(String status) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT 
        d.*,
        s.name as supplier_name
      FROM supply_deliveries d
      LEFT JOIN suppliers s ON d.supplier_id = s.id
      WHERE d.status = ?
      ORDER BY d.created_at DESC
    ''',
      [status],
    );

    return maps.map((map) => SupplyDelivery.fromMap(map)).toList();
  }

  /// Get delivery by ID with items
  Future<SupplyDelivery?> getById(String id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT 
        d.*,
        s.name as supplier_name
      FROM supply_deliveries d
      LEFT JOIN suppliers s ON d.supplier_id = s.id
      WHERE d.id = ?
    ''',
      [id],
    );

    if (maps.isEmpty) return null;

    final delivery = SupplyDelivery.fromMap(maps.first);
    final items = await getItems(delivery.id);
    return delivery.copyWith(items: items);
  }

  /// Get items for a delivery
  Future<List<SupplyDeliveryItem>> getItems(String deliveryId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'supply_delivery_items',
      where: 'delivery_id = ?',
      whereArgs: [deliveryId],
    );
    return maps.map((map) => SupplyDeliveryItem.fromMap(map)).toList();
  }

  /// Create a new delivery with items
  Future<SupplyDelivery> create(
    SupplyDelivery delivery,
    List<SupplyDeliveryItem> items,
  ) async {
    final db = await _db;

    await db.transaction((txn) async {
      await txn.insert('supply_deliveries', delivery.toMap());

      for (final item in items) {
        await txn.insert('supply_delivery_items', item.toMap());
      }
    });

    return delivery.copyWith(items: items);
  }

  /// Confirm delivery: Update status, items stock, and create stock movements
  Future<void> confirmDelivery(String deliveryId, String proofImage) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      // 1. Update delivery status
      await txn.update(
        'supply_deliveries',
        {
          'status': 'completed',
          'delivered_date': now,
          'proof_image': proofImage,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [deliveryId],
      );

      // 2. Get delivery items
      final itemsMaps = await txn.query(
        'supply_delivery_items',
        where: 'delivery_id = ?',
        whereArgs: [deliveryId],
      );
      final items = itemsMaps
          .map((m) => SupplyDeliveryItem.fromMap(m))
          .toList();

      // Get header info for movements
      final deliveryMap = await txn.query(
        'supply_deliveries',
        columns: ['supplier_id'],
        where: 'id = ?',
        whereArgs: [deliveryId],
      );
      final supplierId = deliveryMap.first['supplier_id'] as String;

      // 3. Process each item
      for (final item in items) {
        // Get current stock
        final productMaps = await txn.query(
          'products',
          columns: ['stock'],
          where: 'id = ?',
          whereArgs: [item.productId],
        );

        if (productMaps.isNotEmpty) {
          final currentStock = productMaps.first['stock'] as int;
          final newStock = currentStock + item.quantity;

          // Update product stock
          await txn.update(
            'products',
            {'stock': newStock, 'updated_at': now},
            where: 'id = ?',
            whereArgs: [item.productId],
          );

          // Create stock movement
          await txn.insert('stock_movements', {
            'id': _uuid.v4(),
            'product_id': item.productId,
            'type': 'in',
            'quantity': item.quantity,
            'previous_stock': currentStock,
            'new_stock': newStock,
            'supplier_id': supplierId,
            'reason': 'Delivery #${deliveryId.substring(0, 8)}',
            'created_by': 'admin', // Ideally current user id
            'created_at': now,
          });
        }
      }
    });
  }

  /// Cancel delivery
  Future<void> cancelDelivery(String id) async {
    final db = await _db;
    await db.update(
      'supply_deliveries',
      {'status': 'cancelled', 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete delivery (only if not completed, or simpler logic)
  Future<void> delete(String id) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete(
        'supply_delivery_items',
        where: 'delivery_id = ?',
        whereArgs: [id],
      );
      await txn.delete('supply_deliveries', where: 'id = ?', whereArgs: [id]);
    });
  }
}
