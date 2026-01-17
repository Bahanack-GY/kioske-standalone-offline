import 'package:flutter/foundation.dart';
import 'package:kioske/models/supplier.dart';
import 'package:kioske/models/supplier_stats.dart';
import 'package:kioske/repositories/supplier_repository.dart';

class SupplierProvider extends ChangeNotifier {
  final SupplierRepository _repository = SupplierRepository();

  List<Supplier> _suppliers = [];
  List<SupplierStats> _supplierStats = [];
  bool _isLoading = false;
  String? _error;

  List<Supplier> get suppliers => _suppliers;
  List<SupplierStats> get supplierStats => _supplierStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all active suppliers
  Future<void> loadSuppliers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _repository.getAll();
      final stats = await _repository.getAllWithStats();
      _suppliers = list;
      _supplierStats = stats;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading suppliers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new supplier
  Future<void> addSupplier({
    required String name,
    String? phone,
    String? email,
    String? address,
    String? contactPerson,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final supplier = await _repository.create(
        name: name,
        phone: phone,
        email: email,
        address: address,
        contactPerson: contactPerson,
      );
      _suppliers.add(supplier);
      _suppliers.sort((a, b) => a.name.compareTo(b.name));
      // Reload stats to include new empty stats
      await loadSuppliers();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding supplier: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update existing supplier
  Future<void> updateSupplier(Supplier supplier) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.update(supplier);
      final index = _suppliers.indexWhere((s) => s.id == supplier.id);
      if (index != -1) {
        _suppliers[index] = supplier;
        _suppliers.sort((a, b) => a.name.compareTo(b.name));
      }
      // Reload stats
      await loadSuppliers();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating supplier: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a supplier
  Future<void> deleteSupplier(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.delete(id);
      _suppliers.removeWhere((s) => s.id == id);
      await loadSuppliers();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting supplier: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
