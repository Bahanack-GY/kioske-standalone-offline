class SupplyDeliveryItem {
  final String id;
  final String deliveryId;
  final String productId;
  final String productName; // Denormalized for display
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  SupplyDeliveryItem({
    required this.id,
    required this.deliveryId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory SupplyDeliveryItem.fromMap(Map<String, dynamic> map) {
    return SupplyDeliveryItem(
      id: map['id'] as String,
      deliveryId: map['delivery_id'] as String,
      productId: map['product_id'] as String,
      productName: map['product_name'] as String? ?? 'Unknown Product',
      quantity: map['quantity'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
      totalPrice: (map['total_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'delivery_id': deliveryId,
      'product_id': productId,
      // product_name is typically joined, but we can store it too if snapshotting
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }
}
