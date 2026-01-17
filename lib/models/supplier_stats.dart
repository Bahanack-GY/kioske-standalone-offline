import 'package:kioske/models/supplier.dart';

class SupplierStats {
  final Supplier supplier;
  final int totalDeliveries;
  final double totalAmount;
  final int totalItemsSupplied;
  final List<String> productNames;
  final int otherProductsCount;

  SupplierStats({
    required this.supplier,
    required this.totalDeliveries,
    required this.totalAmount,
    required this.totalItemsSupplied,
    required this.productNames,
    required this.otherProductsCount,
  });
}
