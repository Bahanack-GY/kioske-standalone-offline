/// Product model for inventory items
class Product {
  final String id;
  final String name;
  final String categoryId;
  final double purchasePrice;
  final double salePrice;
  final int stock;
  final String? imageUrl;
  final double rating;
  final String status; // 'available' | 'medium' | 'low'
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.purchasePrice,
    required this.salePrice,
    required this.stock,
    this.imageUrl,
    this.rating = 0.0,
    required this.status,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Calculate margin between sale and purchase price
  double get margin => salePrice - purchasePrice;

  /// Calculate margin percentage
  double get marginPercent =>
      purchasePrice > 0 ? ((margin / purchasePrice) * 100) : 0;

  /// Determine stock status based on quantity
  static String calculateStatus(int stock) {
    if (stock <= 5) return 'low';
    if (stock <= 20) return 'medium';
    return 'available';
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      categoryId: map['category_id'] as String,
      purchasePrice: (map['purchase_price'] as num).toDouble(),
      salePrice: (map['sale_price'] as num).toDouble(),
      stock: map['stock'] as int,
      imageUrl: map['image_url'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String,
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
      'category_id': categoryId,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'stock': stock,
      'image_url': imageUrl,
      'rating': rating,
      'status': status,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? categoryId,
    double? purchasePrice,
    double? salePrice,
    int? stock,
    String? imageUrl,
    double? rating,
    String? status,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
