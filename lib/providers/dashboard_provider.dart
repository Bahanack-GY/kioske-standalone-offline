import 'package:flutter/material.dart';
import 'package:kioske/repositories/order_repository.dart';
import 'package:kioske/repositories/expense_repository.dart';
import 'package:kioske/repositories/customer_repository.dart';

/// Data class for top selling product info
class ProductSalesInfo {
  final String productId;
  final String productName;
  final int quantitySold;
  final double totalRevenue;

  ProductSalesInfo({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.totalRevenue,
  });
}

/// Provider for admin dashboard data with date range filtering
class DashboardProvider extends ChangeNotifier {
  final OrderRepository _orderRepo = OrderRepository();
  final ExpenseRepository _expenseRepo = ExpenseRepository();
  final CustomerRepository _customerRepo = CustomerRepository();

  // Selected date range
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );

  // Loading state
  bool _isLoading = false;

  // Dashboard metrics
  double _totalSales = 0;
  double _mobileMoneySales = 0;
  int _transactionCount = 0;
  double _averageTransaction = 0;
  double _totalExpenses = 0;
  double _grossMargin = 0;
  double _netProfit = 0;
  int _newCustomerCount = 0;
  int _returningCustomerCount = 0;
  Map<int, double> _hourlySales = {};
  List<ProductSalesInfo> _topSellingProducts = [];
  List<ProductSalesInfo> _slowestSellingProducts = [];

  // Getters
  DateTimeRange get selectedDateRange => _selectedDateRange;
  bool get isLoading => _isLoading;
  double get totalSales => _totalSales;
  double get mobileMoneySales => _mobileMoneySales;
  int get transactionCount => _transactionCount;
  double get averageTransaction => _averageTransaction;
  double get totalExpenses => _totalExpenses;
  double get grossMargin => _grossMargin;
  double get netProfit => _netProfit;
  int get newCustomerCount => _newCustomerCount;
  int get returningCustomerCount => _returningCustomerCount;
  Map<int, double> get hourlySales => _hourlySales;
  List<ProductSalesInfo> get topSellingProducts => _topSellingProducts;
  List<ProductSalesInfo> get slowestSellingProducts => _slowestSellingProducts;

  /// Set date range and reload data
  Future<void> setDateRange(DateTimeRange range) async {
    _selectedDateRange = range;
    await loadDashboardData();
  }

  /// Set to today
  Future<void> setToday() async {
    final now = DateTime.now();
    await setDateRange(DateTimeRange(start: now, end: now));
  }

  /// Set to last 7 days
  Future<void> setLast7Days() async {
    final now = DateTime.now();
    await setDateRange(
      DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now),
    );
  }

  /// Set to last 30 days
  Future<void> setLast30Days() async {
    final now = DateTime.now();
    await setDateRange(
      DateTimeRange(start: now.subtract(const Duration(days: 29)), end: now),
    );
  }

  /// Load all dashboard data for the selected date range
  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final start = DateTime(
        _selectedDateRange.start.year,
        _selectedDateRange.start.month,
        _selectedDateRange.start.day,
      );
      final end = DateTime(
        _selectedDateRange.end.year,
        _selectedDateRange.end.month,
        _selectedDateRange.end.day,
        23,
        59,
        59,
      );

      // Fetch sales data
      _totalSales = await _orderRepo.getTotalSales(start, end);
      _mobileMoneySales = await _orderRepo.getMobileMoneySales(start, end);
      _transactionCount = await _orderRepo.getOrderCount(start, end);
      _averageTransaction = _transactionCount > 0
          ? _totalSales / _transactionCount
          : 0;

      // Fetch expenses
      _totalExpenses = await _expenseRepo.getTotalExpenses(start, end);

      // Calculate profit metrics
      _netProfit = _totalSales - _totalExpenses;
      _grossMargin = _totalSales > 0
          ? ((_totalSales - _totalExpenses) / _totalSales) * 100
          : 0;

      // Fetch customer counts
      final customerCounts = await _customerRepo.getCustomerCountsByDateRange(
        start,
        end,
      );
      _newCustomerCount = customerCounts['new'] ?? 0;
      _returningCustomerCount = customerCounts['returning'] ?? 0;

      // Fetch hourly sales (for single day selection)
      if (_selectedDateRange.duration.inDays == 0) {
        _hourlySales = await _orderRepo.getHourlySales(
          _selectedDateRange.start,
        );
      } else {
        // For multi-day ranges, aggregate hourly data
        _hourlySales = await _getAggregatedHourlySales(start, end);
      }

      // Fetch top/slowest selling products
      _topSellingProducts = await _getTopSellingProducts(start, end);
      _slowestSellingProducts = await _getSlowestSellingProducts(start, end);
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get aggregated hourly sales across multiple days
  Future<Map<int, double>> _getAggregatedHourlySales(
    DateTime start,
    DateTime end,
  ) async {
    final orders = await _orderRepo.getByDateRange(start, end);
    final hourlySales = <int, double>{};

    for (final order in orders) {
      if (order.status == 'completed') {
        final hour = order.createdAt.hour;
        hourlySales[hour] = (hourlySales[hour] ?? 0) + order.total;
      }
    }

    return hourlySales;
  }

  /// Get top selling products
  Future<List<ProductSalesInfo>> _getTopSellingProducts(
    DateTime start,
    DateTime end, {
    int limit = 10,
  }) async {
    final orders = await _orderRepo.getByDateRange(start, end);
    final productSales = <String, ProductSalesInfo>{};

    for (final order in orders) {
      if (order.status == 'completed') {
        for (final item in order.items) {
          final existing = productSales[item.productId];
          if (existing != null) {
            productSales[item.productId] = ProductSalesInfo(
              productId: item.productId,
              productName: item.productName,
              quantitySold: existing.quantitySold + item.quantity,
              totalRevenue: existing.totalRevenue + item.total,
            );
          } else {
            productSales[item.productId] = ProductSalesInfo(
              productId: item.productId,
              productName: item.productName,
              quantitySold: item.quantity,
              totalRevenue: item.total,
            );
          }
        }
      }
    }

    final sorted = productSales.values.toList()
      ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold));

    return sorted.take(limit).toList();
  }

  /// Get slowest selling products
  Future<List<ProductSalesInfo>> _getSlowestSellingProducts(
    DateTime start,
    DateTime end, {
    int limit = 10,
  }) async {
    final orders = await _orderRepo.getByDateRange(start, end);
    final productSales = <String, ProductSalesInfo>{};

    for (final order in orders) {
      if (order.status == 'completed') {
        for (final item in order.items) {
          final existing = productSales[item.productId];
          if (existing != null) {
            productSales[item.productId] = ProductSalesInfo(
              productId: item.productId,
              productName: item.productName,
              quantitySold: existing.quantitySold + item.quantity,
              totalRevenue: existing.totalRevenue + item.total,
            );
          } else {
            productSales[item.productId] = ProductSalesInfo(
              productId: item.productId,
              productName: item.productName,
              quantitySold: item.quantity,
              totalRevenue: item.total,
            );
          }
        }
      }
    }

    final sorted = productSales.values.toList()
      ..sort((a, b) => a.quantitySold.compareTo(b.quantitySold));

    return sorted.take(limit).toList();
  }
}
