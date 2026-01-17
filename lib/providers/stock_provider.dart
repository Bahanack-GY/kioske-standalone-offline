import 'package:flutter/material.dart';
import 'package:kioske/models/product.dart';
import 'package:kioske/models/category.dart';
import 'package:kioske/repositories/product_repository.dart';
import 'package:kioske/repositories/category_repository.dart';
import 'package:kioske/repositories/stock_movement_repository.dart';

/// Provider for stock/product management
class StockProvider extends ChangeNotifier {
  final ProductRepository _productRepo = ProductRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  final StockMovementRepository _movementRepo = StockMovementRepository();

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  Map<String, Category> _categoriesMap = {};
  String _selectedFilter = 'all'; // all, available, medium, low
  String _searchQuery = '';
  bool _isLoading = false;

  // Getters
  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _allProducts;
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  // Stock counts
  int get totalCount => _allProducts.length;
  int get goodCount =>
      _allProducts.where((p) => p.status == 'available').length;
  int get mediumCount => _allProducts.where((p) => p.status == 'medium').length;
  int get lowCount => _allProducts.where((p) => p.status == 'low').length;

  /// Get category name for a product
  String getCategoryName(String categoryId) {
    return _categoriesMap[categoryId]?.name ?? 'Unknown';
  }

  /// Load all products from database
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allProducts = await _productRepo.getAll();

      // Load categories for display
      final categories = await _categoryRepo.getAll();
      _categoriesMap = {for (var c in categories) c.id: c};

      _applyFilters();
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set filter and apply
  void setFilter(String filter) {
    _selectedFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  /// Set search query and apply
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Apply current filters to product list
  void _applyFilters() {
    _filteredProducts = _allProducts.where((product) {
      // Apply status filter
      if (_selectedFilter != 'all') {
        if (_selectedFilter == 'good' && product.status != 'available') {
          return false;
        }
        if (_selectedFilter == 'medium' && product.status != 'medium') {
          return false;
        }
        if (_selectedFilter == 'low' && product.status != 'low') {
          return false;
        }
      }

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = product.name.toLowerCase().contains(query);
        final categoryName = getCategoryName(product.categoryId).toLowerCase();
        final categoryMatch = categoryName.contains(query);
        if (!nameMatch && !categoryMatch) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Update product stock
  Future<bool> updateStock(
    String productId,
    int newStock, {
    String? reason,
    String? notes,
    String? createdBy,
  }) async {
    try {
      final product = _allProducts.firstWhere((p) => p.id == productId);
      final previousStock = product.stock;

      // Update stock in database
      await _productRepo.updateStock(productId, newStock);

      // Record movement
      final type = newStock > previousStock ? 'in' : 'out';
      final quantity = (newStock - previousStock).abs();
      await _movementRepo.create(
        productId: productId,
        type: type,
        quantity: quantity,
        previousStock: previousStock,
        newStock: newStock,
        reason: reason,
        notes: notes,
        createdBy: createdBy ?? 'admin',
      );

      // Reload products
      await loadProducts();
      return true;
    } catch (e) {
      debugPrint('Error updating stock: $e');
      return false;
    }
  }

  /// Update full product details
  Future<bool> updateProduct(Product product) async {
    try {
      await _productRepo.update(product);
      await loadProducts();
      return true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      return false;
    }
  }

  /// Get product by ID
  Product? getProductById(String id) {
    try {
      return _allProducts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
