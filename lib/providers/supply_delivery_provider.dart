import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:kioske/models/supply_delivery.dart';
import 'package:kioske/models/supply_delivery_item.dart';
import 'package:kioske/repositories/supply_delivery_repository.dart';
import 'package:kioske/repositories/activity_repository.dart';
import 'package:kioske/models/activity.dart';
import 'package:kioske/data/database_helper.dart';

class SupplyDeliveryProvider extends ChangeNotifier {
  final SupplyDeliveryRepository _repository = SupplyDeliveryRepository();
  final ActivityRepository _activityRepository = ActivityRepository();
  final _uuid = const Uuid();

  List<SupplyDelivery> _deliveries = [];
  bool _isLoading = false;
  String? _error;

  List<SupplyDelivery> get deliveries => _deliveries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all deliveries
  Future<void> loadDeliveries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _repository.getAll();
      _deliveries = list;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading deliveries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new delivery
  Future<void> createDelivery({
    required String supplierId,
    required DateTime expectedDate,
    required List<Map<String, dynamic>>
    itemsData, // [{product, quantity, price}]
    String? notes,
    String? proofImage,
    required String currentUserId,
    String? currentUserName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final deliveryId = _uuid.v4();
      double totalAmount = 0;
      int totalItems = 0;
      final List<SupplyDeliveryItem> items = [];

      for (var item in itemsData) {
        final qty = item['quantity'] as int;
        final price = item['unit_price'] as double;
        final total = qty * price;

        totalAmount += total;
        totalItems += qty;

        items.add(
          SupplyDeliveryItem(
            id: _uuid.v4(),
            deliveryId: deliveryId,
            productId: item['product_id'],
            productName:
                item['product_name'], // Helper for UI before first fetch
            quantity: qty,
            unitPrice: price,
            totalPrice: total,
          ),
        );
      }

      final delivery = SupplyDelivery(
        id: deliveryId,
        supplierId: supplierId,
        supplierName: '', // Will be filled by join on reload
        status: 'pending',
        expectedDate: expectedDate,
        totalAmount: totalAmount,
        itemCount: totalItems,
        proofImage: proofImage,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await _repository.create(delivery, items);

      // Log activity
      await _activityRepository.create(
        Activity(
          id: DatabaseHelper.generateId(),
          userId: currentUserId,
          userName: currentUserName,
          action: 'create',
          entityType: 'delivery',
          entityId: delivery.id,
          description:
              'Delivery created (Items: ${delivery.itemCount}, Amount: ${delivery.totalAmount})',
          createdAt: DateTime.now(),
        ),
      );

      await loadDeliveries(); // Refresh list to get denormalized names
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating delivery: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Confirm a delivery
  Future<void> confirmDelivery(
    String deliveryId,
    String proofImage, {
    required String currentUserId,
    String? currentUserName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.confirmDelivery(deliveryId, proofImage);

      // Log activity
      await _activityRepository.create(
        Activity(
          id: DatabaseHelper.generateId(),
          userId: currentUserId,
          userName: currentUserName,
          action: 'confirm',
          entityType: 'delivery',
          entityId: deliveryId,
          description: 'Delivery confirmed',
          createdAt: DateTime.now(),
        ),
      );

      await loadDeliveries();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error confirming delivery: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cancel a delivery
  Future<void> cancelDelivery(
    String id, {
    required String currentUserId,
    String? currentUserName,
  }) async {
    // Optimistic update
    final index = _deliveries.indexWhere((d) => d.id == id);
    if (index != -1) {
      final old = _deliveries[index];
      _deliveries[index] = old.copyWith(status: 'cancelled');
      notifyListeners();
    }

    try {
      await _repository.cancelDelivery(id);

      // Log activity
      await _activityRepository.create(
        Activity(
          id: DatabaseHelper.generateId(),
          userId: currentUserId,
          userName: currentUserName,
          action: 'cancel',
          entityType: 'delivery',
          entityId: id,
          description: 'Delivery cancelled',
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      // Revert on error
      if (index != -1) {
        // reload needed
        await loadDeliveries();
      }
      rethrow;
    }
  }

  /// Delete a delivery
  Future<void> deleteDelivery(
    String id, {
    required String currentUserId,
    String? currentUserName,
  }) async {
    _deliveries.removeWhere((d) => d.id == id);
    notifyListeners();

    try {
      await _repository.delete(id);

      // Log activity
      await _activityRepository.create(
        Activity(
          id: DatabaseHelper.generateId(),
          userId: currentUserId,
          userName: currentUserName,
          action: 'delete',
          entityType: 'delivery',
          entityId: id,
          description: 'Delivery deleted',
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      await loadDeliveries(); // Revert
      rethrow;
    }
  }

  /// Get detailed items for a delivery (helper)
  Future<List<SupplyDeliveryItem>> getDeliveryItems(String deliveryId) {
    return _repository.getItems(deliveryId);
  }
}
