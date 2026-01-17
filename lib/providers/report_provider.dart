import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kioske/repositories/customer_repository.dart';
import 'package:kioske/repositories/product_repository.dart';
import 'package:kioske/repositories/stock_movement_repository.dart';
import 'package:kioske/repositories/order_repository.dart';
import 'package:kioske/repositories/supply_delivery_repository.dart';
import 'package:kioske/repositories/employee_repository.dart';
import 'package:kioske/repositories/activity_repository.dart';
import 'package:kioske/models/customer.dart';
import 'package:kioske/models/product.dart';
import 'package:kioske/models/stock_movement.dart';
import 'package:kioske/models/supply_delivery.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class ReportProvider with ChangeNotifier {
  final ProductRepository _productRepository = ProductRepository();
  final CustomerRepository _customerRepository = CustomerRepository();
  final StockMovementRepository _stockMovementRepository =
      StockMovementRepository();
  final OrderRepository _orderRepository = OrderRepository();
  final SupplyDeliveryRepository _supplyDeliveryRepository =
      SupplyDeliveryRepository();
  final EmployeeRepository _employeeRepository = EmployeeRepository();
  final ActivityRepository _activityRepository = ActivityRepository();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // -- Data Getters --

  Future<List<Product>> getProductsReport() async {
    return await _productRepository.getAll();
  }

  Future<List<Customer>> getCustomersReport() async {
    return await _customerRepository.getAll();
  }

  Future<List<StockMovement>> getStockMovementsReport() async {
    return await _stockMovementRepository.getAll();
  }

  // -- Sales Reports --

  Future<List<Map<String, dynamic>>> getDailySalesReport(
    DateTime start,
    DateTime end,
  ) async {
    final orders = await _orderRepository.getByDateRange(start, end);
    final salesByDate = <String, double>{};
    final countByDate = <String, int>{};

    for (var order in orders) {
      if (order.status == 'completed') {
        final dateKey = DateFormat('yyyy-MM-dd').format(order.createdAt);
        salesByDate[dateKey] = (salesByDate[dateKey] ?? 0) + order.total;
        countByDate[dateKey] = (countByDate[dateKey] ?? 0) + 1;
      }
    }

    final result = <Map<String, dynamic>>[];
    // Fill in days with 0 if needed (optional, skipping for now)
    salesByDate.forEach((date, total) {
      result.add({
        'date': date,
        'total': total,
        'count': countByDate[date] ?? 0,
      });
    });

    // Sort by date
    result.sort((a, b) => b['date'].compareTo(a['date']));
    return result;
  }

  Future<Map<int, double>> getHourlySalesReport(DateTime date) async {
    return await _orderRepository.getHourlySales(date);
  }

  // -- Purchases Report (Supply Deliveries) --

  Future<List<SupplyDelivery>> getPurchasesReport() async {
    return await _supplyDeliveryRepository.getAll();
  }

  // -- Employee Report --

  Future<List<Map<String, dynamic>>> getEmployeePerformanceReport() async {
    final employees = await _employeeRepository.getAll();
    final result = <Map<String, dynamic>>[];

    for (var emp in employees) {
      // Find user ID associated with employee (if using user_id link) or rely on name?
      // Employee model has userId.
      double totalSales = 0.0;
      double todaySales = 0.0;
      int orderCount = 0;
      DateTime? lastLogin;

      if (emp.userId != null) {
        final orders = await _orderRepository.getByCashier(emp.userId!);
        final now = DateTime.now();
        final startOfToday = DateTime(now.year, now.month, now.day);

        for (var o in orders) {
          if (o.status == 'completed') {
            totalSales += o.total;
            orderCount++;
            if (o.createdAt.isAfter(startOfToday)) {
              todaySales += o.total;
            }
          }
        }

        final activity = await _activityRepository.getLastUserAction(
          emp.userId!,
          'connection', // Must match 'connection' action in AuthProvider
        );
        lastLogin = activity?.createdAt;
      }

      result.add({
        'name': emp.name,
        'role': emp.role,
        'totalSales': totalSales,
        'todaySales': todaySales,
        'orderCount': orderCount,
        'lastLogin': lastLogin,
        'status': emp.status,
      });
    }
    return result;
  }

  // -- Excel Export --

  Future<String?> exportToExcel(String reportType, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      List<List<CellValue>> rows = [];

      // 1. Fetch Data & Build Rows based on Type
      if (reportType == 'products') {
        final products = await getProductsReport();
        // Header
        rows.add([
          TextCellValue('Nom'),
          TextCellValue('Catégorie'),
          TextCellValue('Prix Achat'),
          TextCellValue('Prix Vente'),
          TextCellValue('Stock'),
          TextCellValue('Status'),
        ]);
        // Data
        for (var p in products) {
          rows.add([
            TextCellValue(p.name),
            TextCellValue(p.categoryId), // Ideally Category Name
            TextCellValue(p.purchasePrice.toString()),
            TextCellValue(p.salePrice.toString()),
            IntCellValue(p.stock),
            TextCellValue(p.status),
          ]);
        }
      } else if (reportType == 'clients') {
        final customers = await getCustomersReport();
        // Header
        rows.add([
          TextCellValue('Nom'),
          TextCellValue('Téléphone'),
          TextCellValue('Total Achats'),
          TextCellValue('Commandes'),
        ]);
        // Data
        for (var c in customers) {
          rows.add([
            TextCellValue(c.name),
            TextCellValue(c.phone ?? ''),
            DoubleCellValue(c.totalPurchases),
            IntCellValue(c.orderCount),
          ]);
        }
      } else if (reportType == 'stock_movements') {
        final movements = await getStockMovementsReport();
        rows.add([
          TextCellValue('Date'),
          TextCellValue('Produit'), // ID or fetch name
          TextCellValue('Type'),
          TextCellValue('Quantité'),
          TextCellValue('Raison'),
        ]);
        for (var m in movements) {
          rows.add([
            TextCellValue(DateFormat('yyyy-MM-dd HH:mm').format(m.createdAt)),
            TextCellValue(m.productId),
            TextCellValue(m.type),
            IntCellValue(m.quantity),
            TextCellValue(m.reason ?? ''),
          ]);
        }
      } else if (reportType == 'sales_daily') {
        final end = DateTime.now();
        final start = end.subtract(const Duration(days: 30));
        final data = await getDailySalesReport(start, end);
        rows.add([
          TextCellValue('Date'),
          TextCellValue('Total (FCFA)'),
          TextCellValue('Nombre de Commandes'),
        ]);
        for (var d in data) {
          rows.add([
            TextCellValue(d['date'] as String),
            DoubleCellValue(d['total'] as double),
            IntCellValue(d['count'] as int),
          ]);
        }
      } else if (reportType == 'sales_hourly') {
        final date = DateTime.now();
        final data = await getHourlySalesReport(date);
        rows.add([TextCellValue('Heure'), TextCellValue('Ventes (FCFA)')]);
        for (int i = 0; i < 24; i++) {
          rows.add([TextCellValue('$i:00'), DoubleCellValue(data[i] ?? 0.0)]);
        }
      } else if (reportType == 'purchases') {
        final purchases = await getPurchasesReport();
        rows.add([
          TextCellValue('Fournisseur'),
          TextCellValue('Status'),
          TextCellValue('Total (FCFA)'),
          TextCellValue('Date'),
        ]);
        for (var p in purchases) {
          rows.add([
            TextCellValue(p.supplierName),
            TextCellValue(p.status),
            DoubleCellValue(p.totalAmount),
            TextCellValue(DateFormat('yyyy-MM-dd').format(p.createdAt)),
          ]);
        }
      } else if (reportType == 'employees') {
        final data = await getEmployeePerformanceReport();
        rows.add([
          TextCellValue('Nom'),
          TextCellValue('Rôle'),
          TextCellValue('Ventes Totales'),
          TextCellValue('Ventes Aujourd\'hui'),
          TextCellValue('Commandes'),
          TextCellValue('Dernière Connexion'),
        ]);
        for (var e in data) {
          rows.add([
            TextCellValue(e['name'] as String),
            TextCellValue(e['role'] as String),
            DoubleCellValue(e['totalSales'] as double),
            DoubleCellValue(e['todaySales'] as double),
            IntCellValue(e['orderCount'] as int),
            TextCellValue(
              e['lastLogin'] != null
                  ? DateFormat(
                      'yyyy-MM-dd HH:mm',
                    ).format(e['lastLogin'] as DateTime)
                  : 'Jamais',
            ),
          ]);
        }
      } else {
        throw Exception("Report type '$reportType' not supported yet.");
      }

      // 2. Write Rows to Sheet
      for (var row in rows) {
        sheetObject.appendRow(row);
      }

      // 3. Save File
      final directory = await getApplicationDocumentsDirectory();
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'report_${reportType}_$dateStr.xlsx';
      final path = '${directory.path}/$fileName';

      final fileBytes = excel.save();
      if (fileBytes != null) {
        File(path)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);

        // 4. Open File (Optional)
        await OpenFile.open(path);

        return path;
      }
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error exporting report: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
