import 'package:kioske/models/supply_delivery_item.dart';

class SupplyDelivery {
  final String id;
  final String supplierId;
  final String supplierName; // Denormalized or joined
  final String status; // 'pending', 'completed', 'cancelled'
  final DateTime expectedDate;
  final DateTime? deliveredDate;
  final double totalAmount;
  final int itemCount;
  final String? proofImage; // Base64 or path
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<SupplyDeliveryItem> items;

  SupplyDelivery({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.status,
    required this.expectedDate,
    this.deliveredDate,
    required this.totalAmount,
    required this.itemCount,
    this.proofImage,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  factory SupplyDelivery.fromMap(
    Map<String, dynamic> map, {
    List<SupplyDeliveryItem>? items,
  }) {
    return SupplyDelivery(
      id: map['id'] as String,
      supplierId: map['supplier_id'] as String,
      supplierName:
          map['supplier_name'] as String? ??
          'Unknown Supplier', // Typically from join
      status: map['status'] as String,
      expectedDate: DateTime.parse(map['expected_date'] as String),
      deliveredDate: map['delivered_date'] != null
          ? DateTime.parse(map['delivered_date'] as String)
          : null,
      totalAmount: (map['total_amount'] as num).toDouble(),
      itemCount: map['item_count'] as int,
      proofImage: map['proof_image'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      items: items ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplier_id': supplierId,
      'status': status,
      'expected_date': expectedDate.toIso8601String(),
      'delivered_date': deliveredDate?.toIso8601String(),
      'total_amount': totalAmount,
      'item_count': itemCount,
      'proof_image': proofImage,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SupplyDelivery copyWith({
    String? id,
    String? supplierId,
    String? supplierName,
    String? status,
    DateTime? expectedDate,
    DateTime? deliveredDate,
    double? totalAmount,
    int? itemCount,
    String? proofImage,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<SupplyDeliveryItem>? items,
  }) {
    return SupplyDelivery(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      status: status ?? this.status,
      expectedDate: expectedDate ?? this.expectedDate,
      deliveredDate: deliveredDate ?? this.deliveredDate,
      totalAmount: totalAmount ?? this.totalAmount,
      itemCount: itemCount ?? this.itemCount,
      proofImage: proofImage ?? this.proofImage,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}
