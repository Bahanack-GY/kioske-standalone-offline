/// Promotion model for promotional offers and discounts
class Promotion {
  final String id;
  final String title;
  final String? description;
  final String type; // 'percentage' | 'fixed_amount' | 'buy_x_get_y'
  final double value; // Discount percentage or fixed amount
  final double? minimumPurchase;
  final String? productId; // If promotion applies to specific product
  final String? categoryId; // If promotion applies to category
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Promotion({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.value,
    this.minimumPurchase,
    this.productId,
    this.categoryId,
    this.isActive = true,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.updatedAt,
  });

  /// Check if promotion is currently valid
  bool get isValid {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }

  factory Promotion.fromMap(Map<String, dynamic> map) {
    return Promotion(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      type: map['type'] as String,
      value: (map['value'] as num).toDouble(),
      minimumPurchase: (map['minimum_purchase'] as num?)?.toDouble(),
      productId: map['product_id'] as String?,
      categoryId: map['category_id'] as String?,
      isActive: (map['is_active'] as int) == 1,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'value': value,
      'minimum_purchase': minimumPurchase,
      'product_id': productId,
      'category_id': categoryId,
      'is_active': isActive ? 1 : 0,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Promotion copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    double? value,
    double? minimumPurchase,
    String? productId,
    String? categoryId,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Promotion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      minimumPurchase: minimumPurchase ?? this.minimumPurchase,
      productId: productId ?? this.productId,
      categoryId: categoryId ?? this.categoryId,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
