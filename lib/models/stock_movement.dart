/// Stock movement model for inventory tracking
class StockMovement {
  final String id;
  final String productId;
  final String type; // 'in' | 'out' | 'adjustment'
  final int quantity;
  final int previousStock;
  final int newStock;
  final String? supplierId;
  final String? orderId;
  final String? reason;
  final String? notes;
  final String createdBy; // User ID
  final DateTime createdAt;

  StockMovement({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    this.supplierId,
    this.orderId,
    this.reason,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });

  factory StockMovement.fromMap(Map<String, dynamic> map) {
    return StockMovement(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      type: map['type'] as String,
      quantity: map['quantity'] as int,
      previousStock: map['previous_stock'] as int,
      newStock: map['new_stock'] as int,
      supplierId: map['supplier_id'] as String?,
      orderId: map['order_id'] as String?,
      reason: map['reason'] as String?,
      notes: map['notes'] as String?,
      createdBy: map['created_by'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'type': type,
      'quantity': quantity,
      'previous_stock': previousStock,
      'new_stock': newStock,
      'supplier_id': supplierId,
      'order_id': orderId,
      'reason': reason,
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
