/// Supplier model for vendor management
class Supplier {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? contactPerson;
  final double totalOrders;
  final int orderCount;
  final String status; // 'active' | 'inactive' | 'blacklisted'
  final DateTime createdAt;
  final DateTime? updatedAt;

  Supplier({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.contactPerson,
    this.totalOrders = 0.0,
    this.orderCount = 0,
    this.status = 'active',
    required this.createdAt,
    this.updatedAt,
  });

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      contactPerson: map['contact_person'] as String?,
      totalOrders: (map['total_orders'] as num?)?.toDouble() ?? 0.0,
      orderCount: map['order_count'] as int? ?? 0,
      status: map['status'] as String? ?? 'active',
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
      'contact_person': contactPerson,
      'total_orders': totalOrders,
      'order_count': orderCount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Supplier copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? contactPerson,
    double? totalOrders,
    int? orderCount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      contactPerson: contactPerson ?? this.contactPerson,
      totalOrders: totalOrders ?? this.totalOrders,
      orderCount: orderCount ?? this.orderCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
