/// Employee model for staff management
class Employee {
  final String id;
  final String name;
  final String role; // 'admin' | 'cashier' | 'manager' | 'stock_keeper'
  final String? phone;
  final String? email;
  final double salary;
  final String status; // 'active' | 'inactive' | 'on_leave'
  final DateTime hireDate;
  final String? userId; // Link to User model if employee has login access
  final DateTime createdAt;
  final DateTime? updatedAt;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    this.phone,
    this.email,
    this.salary = 0.0,
    this.status = 'active',
    required this.hireDate,
    this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] as String,
      name: map['name'] as String,
      role: map['role'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      salary: (map['salary'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'active',
      hireDate: DateTime.parse(map['hire_date'] as String),
      userId: map['user_id'] as String?,
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
      'role': role,
      'phone': phone,
      'email': email,
      'salary': salary,
      'status': status,
      'hire_date': hireDate.toIso8601String(),
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Employee copyWith({
    String? id,
    String? name,
    String? role,
    String? phone,
    String? email,
    double? salary,
    String? status,
    DateTime? hireDate,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      salary: salary ?? this.salary,
      status: status ?? this.status,
      hireDate: hireDate ?? this.hireDate,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
