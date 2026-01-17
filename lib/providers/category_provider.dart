import 'package:flutter/foundation.dart' hide Category;
import 'package:kioske/models/category.dart';
import 'package:kioske/repositories/category_repository.dart';

/// Provider for category state management
class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _categoryRepository = CategoryRepository();

  List<Category> _categories = [];
  Map<String, int> _productCounts = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<Category> get categories => _categories;
  Map<String, int> get productCounts => _productCounts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all categories
  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _categoryRepository.getAll();
      _productCounts = await _categoryRepository.getProductCounts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load categories: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get category by ID
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get product count for category
  int getProductCount(String categoryId) {
    return _productCounts[categoryId] ?? 0;
  }

  /// Add a new category
  Future<Category?> addCategory({
    required String name,
    String? icon,
    int sortOrder = 0,
  }) async {
    try {
      final category = await _categoryRepository.create(
        name: name,
        icon: icon,
        sortOrder: sortOrder,
      );
      _categories.add(category);
      _productCounts[category.id] = 0;
      notifyListeners();
      return category;
    } catch (e) {
      _errorMessage = 'Failed to add category: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// Update an existing category
  Future<bool> updateCategory(Category category) async {
    try {
      await _categoryRepository.update(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update category: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Delete a category
  Future<bool> deleteCategory(String id) async {
    try {
      await _categoryRepository.deactivate(id);
      _categories.removeWhere((c) => c.id == id);
      _productCounts.remove(id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete category: ${e.toString()}';
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
