import 'package:flutter/foundation.dart';
import 'package:kioske/models/customer.dart';
import 'package:kioske/repositories/customer_repository.dart';
import 'package:kioske/repositories/activity_repository.dart';
import 'package:kioske/models/activity.dart';
import 'package:kioske/data/database_helper.dart';

/// Provider for customer state management
class CustomerProvider extends ChangeNotifier {
  final CustomerRepository _customerRepository = CustomerRepository();
  final ActivityRepository _activityRepository = ActivityRepository();

  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  String _searchQuery = '';
  String? _selectedStatus;
  bool _isLoading = false;
  String? _errorMessage;

  List<Customer> get customers => _customers;
  List<Customer> get filteredCustomers => _filteredCustomers;
  String get searchQuery => _searchQuery;
  String? get selectedStatus => _selectedStatus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all customers
  Future<void> loadCustomers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _customers = await _customerRepository.getAll();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load customers: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search customers
  void search(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  /// Filter by status
  void filterByStatus(String? status) {
    _selectedStatus = status;
    _applyFilters();
    notifyListeners();
  }

  /// Apply all filters
  void _applyFilters() {
    _filteredCustomers = _customers.where((customer) {
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final matchesName = customer.name.toLowerCase().contains(_searchQuery);
        final matchesPhone =
            customer.phone?.toLowerCase().contains(_searchQuery) ?? false;
        if (!matchesName && !matchesPhone) return false;
      }

      // Apply status filter
      if (_selectedStatus != null && customer.status != _selectedStatus) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedStatus = null;
    _filteredCustomers = _customers;
    notifyListeners();
  }

  /// Get customer by ID
  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Add a new customer
  Future<Customer?> addCustomer({
    required String name,
    String? phone,
    String? email,
    String? address,
    required String currentUserId,
    String? currentUserName,
  }) async {
    try {
      final customer = await _customerRepository.create(
        name: name,
        phone: phone,
        email: email,
        address: address,
      );
      _customers.add(customer);
      _applyFilters();
      notifyListeners();

      // Log activity
      await _activityRepository.create(
        Activity(
          id: DatabaseHelper.generateId(),
          userId: currentUserId,
          userName: currentUserName,
          action: 'create',
          entityType: 'customer',
          entityId: customer.id,
          description: 'Customer created: ${customer.name}',
          createdAt: DateTime.now(),
        ),
      );

      return customer;
    } catch (e) {
      _errorMessage = 'Failed to add customer: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// Update an existing customer
  Future<bool> updateCustomer(
    Customer customer, {
    required String currentUserId,
    String? currentUserName,
  }) async {
    try {
      await _customerRepository.update(customer);
      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _customers[index] = customer;
        _applyFilters();
        notifyListeners();

        // Log activity
        await _activityRepository.create(
          Activity(
            id: DatabaseHelper.generateId(),
            userId: currentUserId,
            userName: currentUserName,
            action: 'update',
            entityType: 'customer',
            entityId: customer.id,
            description: 'Customer updated: ${customer.name}',
            createdAt: DateTime.now(),
          ),
        );
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update customer: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Delete a customer
  Future<bool> deleteCustomer(
    String id, {
    required String currentUserId,
    String? currentUserName,
  }) async {
    try {
      await _customerRepository.deactivate(id);
      _customers.removeWhere((c) => c.id == id);
      _applyFilters();
      notifyListeners();

      // Log activity
      await _activityRepository.create(
        Activity(
          id: DatabaseHelper.generateId(),
          userId: currentUserId,
          userName: currentUserName,
          action: 'delete',
          entityType: 'customer',
          entityId: id,
          description: 'Customer deleted',
          createdAt: DateTime.now(),
        ),
      );

      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete customer: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Get VIP customers
  List<Customer> get vipCustomers {
    return _customers.where((c) => c.status == 'vip').toList();
  }

  /// Get customer count
  int get totalCount => _customers.length;

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
