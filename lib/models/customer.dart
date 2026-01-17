/// Customer model for customer management
class Customer {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final double totalPurchases;
  final int orderCount;
  final String status; // 'regular' | 'vip' | 'new'
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.totalPurchases = 0.0,
    this.orderCount = 0,
    this.status = 'new',
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Determine customer tier based on total purchases
  static String calculateStatus(double totalPurchases, int orderCount) {
    if (totalPurchases >= 500000 || orderCount >= 50) return 'vip';
    if (orderCount >= 5) return 'regular';
    return 'new';
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      totalPurchases: (map['total_purchases'] as num?)?.toDouble() ?? 0.0,
      orderCount: map['order_count'] as int? ?? 0,
      status: map['status'] as String? ?? 'new',
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'total_purchases': totalPurchases,
      'order_count': orderCount,
      'status': status,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    double? totalPurchases,
    int? orderCount,
    String? status,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      orderCount: orderCount ?? this.orderCount,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
