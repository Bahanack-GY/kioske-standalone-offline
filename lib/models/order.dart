import 'dart:convert';

/// Order model for sales transactions
class Order {
  final String id;
  final String? customerId;
  final String cashierId;
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final double total;
  final String type; // 'dine_in' | 'delivery'
  final String status; // 'pending' | 'completed' | 'cancelled'
  final String? notes;
  final String paymentMethod; // 'cash' | 'om' | 'momo'
  final DateTime createdAt;
  final DateTime? completedAt;

  Order({
    required this.id,
    this.customerId,
    required this.cashierId,
    required this.items,
    required this.subtotal,
    this.discount = 0.0,
    required this.total,
    required this.type,
    this.status = 'pending',
    this.notes,
    this.paymentMethod = 'cash',
    required this.createdAt,
    this.completedAt,
  });

  /// Calculate totals from items
  factory Order.calculateFromItems({
    required String id,
    String? customerId,
    required String cashierId,
    required List<OrderItem> items,
    double discount = 0.0,
    required String type,
    String? notes,
    String paymentMethod = 'cash',
  }) {
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.total);
    return Order(
      id: id,
      customerId: customerId,
      cashierId: cashierId,
      items: items,
      subtotal: subtotal,
      discount: discount,
      total: subtotal - discount,
      type: type,
      notes: notes,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
    );
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    final itemsJson = map['items'] as String;
    final itemsList = jsonDecode(itemsJson) as List<dynamic>;

    return Order(
      id: map['id'] as String,
      customerId: map['customer_id'] as String?,
      cashierId: map['cashier_id'] as String,
      items: itemsList
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      subtotal: (map['subtotal'] as num).toDouble(),
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num).toDouble(),
      type: map['type'] as String,
      status: map['status'] as String,
      notes: map['notes'] as String?,
      paymentMethod: map['payment_method'] as String? ?? 'cash',
      createdAt: DateTime.parse(map['created_at'] as String),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'cashier_id': cashierId,
      'items': jsonEncode(items.map((item) => item.toMap()).toList()),
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'type': type,
      'status': status,
      'notes': notes,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  Order copyWith({
    String? id,
    String? customerId,
    String? cashierId,
    List<OrderItem>? items,
    double? subtotal,
    double? discount,
    double? total,
    String? type,
    String? status,
    String? notes,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      cashierId: cashierId ?? this.cashierId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      type: type ?? this.type,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Get JSON string representation of items
  String get itemsJson =>
      jsonEncode(items.map((item) => item.toMap()).toList());
}

/// Individual item within an order
class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['product_id'] as String,
      productName: map['product_name'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }

  OrderItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}
