/// Delivery model for delivery order tracking
class Delivery {
  final String id;
  final String orderId;
  final String? customerId;
  final String? driverName;
  final String? driverPhone;
  final String address;
  final String status; // 'pending' | 'in_progress' | 'delivered' | 'cancelled'
  final double deliveryFee;
  final String? notes;
  final DateTime? estimatedDelivery;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Delivery({
    required this.id,
    required this.orderId,
    this.customerId,
    this.driverName,
    this.driverPhone,
    required this.address,
    this.status = 'pending',
    this.deliveryFee = 0.0,
    this.notes,
    this.estimatedDelivery,
    this.deliveredAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory Delivery.fromMap(Map<String, dynamic> map) {
    return Delivery(
      id: map['id'] as String,
      orderId: map['order_id'] as String,
      customerId: map['customer_id'] as String?,
      driverName: map['driver_name'] as String?,
      driverPhone: map['driver_phone'] as String?,
      address: map['address'] as String,
      status: map['status'] as String? ?? 'pending',
      deliveryFee: (map['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] as String?,
      estimatedDelivery: map['estimated_delivery'] != null
          ? DateTime.parse(map['estimated_delivery'] as String)
          : null,
      deliveredAt: map['delivered_at'] != null
          ? DateTime.parse(map['delivered_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'customer_id': customerId,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'address': address,
      'status': status,
      'delivery_fee': deliveryFee,
      'notes': notes,
      'estimated_delivery': estimatedDelivery?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Delivery copyWith({
    String? id,
    String? orderId,
    String? customerId,
    String? driverName,
    String? driverPhone,
    String? address,
    String? status,
    double? deliveryFee,
    String? notes,
    DateTime? estimatedDelivery,
    DateTime? deliveredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Delivery(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      address: address ?? this.address,
      status: status ?? this.status,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      notes: notes ?? this.notes,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
