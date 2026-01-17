import 'package:flutter/foundation.dart';
import 'package:kioske/data/database_helper.dart';
import 'package:kioske/models/order.dart';
import 'package:kioske/models/product.dart';
import 'package:kioske/repositories/order_repository.dart';
import 'package:kioske/repositories/product_repository.dart';
import 'package:kioske/repositories/customer_repository.dart';
import 'package:kioske/repositories/activity_repository.dart';
import 'package:kioske/models/activity.dart';

/// Provider for order/cart state management (POS functionality)
class OrderProvider extends ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();
  final ProductRepository _productRepository = ProductRepository();
  final CustomerRepository _customerRepository = CustomerRepository();
  final ActivityRepository _activityRepository = ActivityRepository();

  List<OrderItem> _cart = [];
  String? _selectedCustomerId;
  String _orderType = 'dine_in';
  double _discount = 0.0;
  String? _notes;
  String _paymentMethod = 'cash'; // 'cash', 'om', 'momo'
  bool _isLoading = false;
  String? _errorMessage;

  // Recent orders for display
  List<Order> _recentOrders = [];
  List<Order> _todayOrders = [];

  List<OrderItem> get cart => _cart;
  String? get selectedCustomerId => _selectedCustomerId;
  String get orderType => _orderType;
  double get discount => _discount;
  String? get notes => _notes;
  String get paymentMethod => _paymentMethod;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Order> get recentOrders => _recentOrders;
  List<Order> get todayOrders => _todayOrders;

  /// Calculate subtotal
  double get subtotal {
    return _cart.fold(0.0, (sum, item) => sum + item.total);
  }

  /// Calculate total (after discount)
  double get total => subtotal - _discount;

  /// Check if cart is empty
  bool get isEmpty => _cart.isEmpty;

  /// Get cart item count
  int get itemCount => _cart.length;

  /// Get total quantity
  int get totalQuantity {
    return _cart.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Add product to cart
  void addToCart(Product product) {
    if (product.stock <= 0) {
      _errorMessage = 'Produit en rupture de stock';
      notifyListeners();
      return;
    }

    final existingIndex = _cart.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingIndex != -1) {
      // Increase quantity only if stock allow
      final existingItem = _cart[existingIndex];
      if (existingItem.quantity < product.stock) {
        _cart[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + 1,
        );
      } else {
        _errorMessage = 'Stock maximum atteint';
        notifyListeners();
        return;
      }
    } else {
      // Add new item
      _cart.add(
        OrderItem(
          productId: product.id,
          productName: product.name,
          quantity: 1,
          unitPrice: product.salePrice,
        ),
      );
    }
    _errorMessage = null;
    notifyListeners();
  }

  /// Remove item from cart
  void removeFromCart(int index) {
    if (index >= 0 && index < _cart.length) {
      _cart.removeAt(index);
      notifyListeners();
    }
  }

  /// Update item quantity with stock check
  void updateQuantity(int index, int delta, {int? maxStock}) {
    if (index >= 0 && index < _cart.length) {
      final newQuantity = _cart[index].quantity + delta;

      if (delta > 0 && maxStock != null && newQuantity > maxStock) {
        _errorMessage = 'Stock maximum atteint';
        notifyListeners();
        return;
      }

      if (newQuantity > 0) {
        _cart[index] = _cart[index].copyWith(quantity: newQuantity);
        _errorMessage = null;
        notifyListeners();
      } else if (newQuantity <= 0) {
        removeFromCart(index);
      }
    }
  }

  /// Set item quantity directly
  void setQuantity(int index, int quantity) {
    if (index >= 0 && index < _cart.length && quantity > 0) {
      _cart[index] = _cart[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  /// Clear cart
  void clearCart() {
    _cart = [];
    _discount = 0.0;
    _notes = null;
    _paymentMethod = 'cash';
    notifyListeners();
  }

  /// Set selected customer
  void setCustomer(String? customerId) {
    _selectedCustomerId = customerId;
    notifyListeners();
  }

  /// Set order type (dine_in or delivery)
  void setOrderType(String type) {
    _orderType = type;
    notifyListeners();
  }

  /// Set discount
  void setDiscount(double discount) {
    _discount = discount;
    notifyListeners();
  }

  /// Set notes
  void setNotes(String? notes) {
    _notes = notes;
    notifyListeners();
  }

  /// Set payment method
  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  /// Complete order
  Future<Order?> completeOrder(String cashierId, {String? cashierName}) async {
    if (_cart.isEmpty) {
      _errorMessage = 'Cart is empty';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create order
      final order = Order.calculateFromItems(
        id: DatabaseHelper.generateId(),
        customerId: _selectedCustomerId,
        cashierId: cashierId,
        items: List.from(_cart),
        discount: _discount,
        type: _orderType,
        notes: _notes,
        paymentMethod: _paymentMethod,
      );

      // Save to database
      final savedOrder = await _orderRepository.create(order);

      // Decrease stock for each product
      for (final item in _cart) {
        await _productRepository.decreaseStock(
          item.productId,
          item.quantity,
          userId: cashierId,
          orderId: savedOrder.id,
          reason: 'Sale #${savedOrder.id.substring(0, 8)}',
        );
      }

      // Update customer stats if customer selected
      if (_selectedCustomerId != null) {
        await _customerRepository.updatePurchaseStats(
          _selectedCustomerId!,
          order.total,
        );
      }

      // Mark as completed
      await _orderRepository.completeOrder(savedOrder.id);

      // Log activity (using savedOrder info)
      await _activityRepository.create(
        Activity(
          id: DatabaseHelper.generateId(),
          userId: cashierId,
          userName: cashierName,
          action: 'sale',
          entityType: 'order',
          entityId: savedOrder.id,
          description: 'Sale completed. Total: ${savedOrder.total}',
          metadata: 'Items: ${savedOrder.itemsJson}',
          createdAt: DateTime.now(),
        ),
      );

      // Clear cart after everything else is done
      clearCart();
      _selectedCustomerId = null;

      // Refresh today's orders
      await loadTodayOrders();

      _isLoading = false;
      notifyListeners();

      return savedOrder;
    } catch (e) {
      _errorMessage = 'Failed to complete order: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Load recent orders
  Future<void> loadRecentOrders({int limit = 10}) async {
    try {
      _recentOrders = await _orderRepository.getAll(limit: limit);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load orders: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Load today's orders
  Future<void> loadTodayOrders() async {
    try {
      _todayOrders = await _orderRepository.getToday();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load today orders: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Get today's total sales
  Future<double> getTodaySales() async {
    return _orderRepository.getTodaySales();
  }

  /// Get today's order count
  Future<int> getTodayOrderCount() async {
    return _orderRepository.getTodayOrderCount();
  }

  /// Cancel an order
  Future<bool> cancelOrder(
    String orderId, {
    required String currentUserId,
    String? currentUserName,
  }) async {
    try {
      await _orderRepository.cancelOrder(orderId);

      // Log activity
      await _activityRepository.create(
        Activity(
          id: DatabaseHelper.generateId(),
          userId: currentUserId,
          userName: currentUserName,
          action: 'cancel',
          entityType: 'order',
          entityId: orderId,
          description: 'Order cancelled',
          createdAt: DateTime.now(),
        ),
      );

      await loadTodayOrders();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to cancel order: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
