import 'package:flutter/material.dart';
import 'package:kioske/models/promotion.dart';
import 'package:kioske/repositories/promotion_repository.dart';

class PromotionProvider with ChangeNotifier {
  final PromotionRepository _repository = PromotionRepository();
  List<Promotion> _promotions = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter states
  String _searchQuery = '';
  String _selectedStatus =
      'Toutes'; // 'Toutes', 'Active', 'Expired', 'Inactive'
  String _selectedType = 'Tous'; // 'Tous', 'percentage', 'fixed_amount', etc.

  List<Promotion> get promotions => _promotions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Filter getters
  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;
  String get selectedType => _selectedType;

  List<Promotion> get filteredPromotions {
    return _promotions.where((promo) {
      // 1. Search Query
      final matchesSearch =
          promo.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (promo.description?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false);

      if (!matchesSearch) return false;

      // 2. Status Filter
      bool matchesStatus = true;
      final now = DateTime.now();
      if (_selectedStatus == 'Active') {
        matchesStatus =
            promo.isActive &&
            now.isAfter(promo.startDate) &&
            now.isBefore(promo.endDate);
      } else if (_selectedStatus == 'Expired') {
        matchesStatus = now.isAfter(promo.endDate);
      } else if (_selectedStatus == 'Inactive') {
        matchesStatus = !promo.isActive;
      }

      if (!matchesStatus) return false;

      // 3. Type Filter
      if (_selectedType != 'Tous' && promo.type != _selectedType) {
        // Note: 'percentage' etc are lowercase in DB
        // Mapping might be needed if UI uses capitalized
        // Ideally keep consistent keys
        return false;
      }

      return true;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setTypeFilter(String type) {
    _selectedType = type;
    notifyListeners();
  }

  Future<void> loadPromotions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _promotions = await _repository.getAll();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error loading promotions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPromotion({
    required String title,
    String? description,
    required String type,
    required double value,
    double? minimumPurchase,
    String? productId,
    String? categoryId,
    required DateTime startDate,
    required DateTime endDate,
    bool isActive = true,
  }) async {
    _isLoading = true; // Optional: separate loading state for actions
    notifyListeners();
    try {
      final newPromo = await _repository.create(
        title: title,
        description: description,
        type: type,
        value: value,
        minimumPurchase: minimumPurchase,
        productId: productId,
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
        isActive: isActive,
      );
      _promotions.insert(0, newPromo);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error adding promotion: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePromotion(Promotion promotion) async {
    try {
      await _repository.update(promotion);
      final index = _promotions.indexWhere((p) => p.id == promotion.id);
      if (index != -1) {
        _promotions[index] = promotion;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating promotion: $e');
      rethrow;
    }
  }

  Future<void> deletePromotion(String id) async {
    try {
      await _repository.delete(id);
      _promotions.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting promotion: $e');
      rethrow;
    }
  }
}
