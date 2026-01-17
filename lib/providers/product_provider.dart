import 'package:flutter/foundation.dart';
import 'package:kioske/models/product.dart';
import 'package:kioske/repositories/product_repository.dart';
import 'package:kioske/repositories/activity_repository.dart';
import 'package:kioske/models/activity.dart';
import 'package:kioske/data/database_helper.dart';

/// Provider for product state management
class ProductProvider extends ChangeNotifier {
  final ProductRepository _productRepository = ProductRepository();
  final ActivityRepository _activityRepository = ActivityRepository();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String? _selectedCategoryId;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;
  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all products
  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _productRepository.getAll();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load products: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter products by category
  void filterByCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilters();
    notifyListeners();
  }

  /// Search products
  void search(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  /// Apply all filters
  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      // Apply category filter
      if (_selectedCategoryId != null &&
          product.categoryId != _selectedCategoryId) {
        return false;
      }

      // Apply search filter
      if (_searchQuery.isNotEmpty &&
          !product.name.toLowerCase().contains(_searchQuery)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Clear all filters
  void clearFilters() {
    _selectedCategoryId = null;
    _searchQuery = '';
    _filteredProducts = _products;
    notifyListeners();
  }

  /// Get product by ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get products with low stock
  List<Product> getLowStockProducts({int threshold = 10}) {
    return _products.where((p) => p.stock <= threshold).toList();
  }

  /// Add a new product
  Future<Product?> addProduct({
    required String name,
    required String categoryId,
    required double purchasePrice,
    required double salePrice,
    required int stock,
    String? imageUrl,
    required String currentUserId,
    String? currentUserName,
  }) async {
    try {
      final product = await _productRepository.create(
        name: name,
        categoryId: categoryId,
        purchasePrice: purchasePrice,
        salePrice: salePrice,
        stock: stock,
        imageUrl: imageUrl,
      );
      _products.add(product);
      _applyFilters();
      notifyListeners();

      // Log activity
      await _activityRepository.create(
        Activity(
          id: DatabaseHelper.generateId(),
          userId: currentUserId,
          userName: currentUserName,
          action: 'create',
          entityType: 'product',
          entityId: product.id,
          description: 'Product created: ${product.name}',
          createdAt: DateTime.now(),
        ),
      );

      return product;
    } catch (e) {
      _errorMessage = 'Failed to add product: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// Update an existing product
  Future<bool> updateProduct(
    Product product, {
    required String currentUserId,
    String? currentUserName,
  }) async {
    try {
      await _productRepository.update(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        _applyFilters();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update product: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Update product stock
  Future<bool> updateStock(String productId, int newStock) async {
    try {
      await _productRepository.updateStock(productId, newStock);
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = _products[index].copyWith(
          stock: newStock,
          status: Product.calculateStatus(newStock),
        );
        _applyFilters();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update stock: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Decrease stock for a sale
  Future<bool> decreaseStock(
    String productId,
    int quantity, {
    required String userId,
    String? orderId,
  }) async {
    try {
      final success = await _productRepository.decreaseStock(
        productId,
        quantity,
        userId: userId,
        orderId: orderId,
      );
      if (success) {
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          final newStock = _products[index].stock - quantity;
          _products[index] = _products[index].copyWith(
            stock: newStock,
            status: Product.calculateStatus(newStock),
          );
          _applyFilters();
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to decrease stock: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Delete a product
  Future<bool> deleteProduct(
    String id, {
    required String currentUserId,
    String? currentUserName,
  }) async {
    try {
      await _productRepository.deactivate(id);
      _products.removeWhere((p) => p.id == id);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete product: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Get total product count
  int get totalCount => _products.length;

  /// Get total stock value
  Future<double> getTotalStockValue() async {
    return _productRepository.getTotalStockValue();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
