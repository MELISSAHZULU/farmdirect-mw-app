// lib/models/product.dart
class Product {
  final int id;
  final String name;
  final int? category;
  final String categoryName;
  final String unit;
  final double price;
  final double? minPrice;
  final double? maxPrice;
  final bool hasVariants;
  final String? imageUrl;
  final String? description;
  final int? farmerId;
  final String farmerName;
  final bool isActive;
  final String createdAt;

  Product({
    required this.id,
    required this.name,
    this.category,
    required this.categoryName,
    required this.unit,
    required this.price,
    this.minPrice,
    this.maxPrice,
    required this.hasVariants,
    this.imageUrl,
    this.description,
    this.farmerId,
    required this.farmerName,
    required this.isActive,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse price
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Product',
      category: json['category'],
      categoryName: json['category_name'] ?? 'Uncategorized',
      unit: json['unit'] ?? 'kg',
      price: parsePrice(json['price']),
      minPrice: json['min_price'] != null ? parsePrice(json['min_price']) : null,
      maxPrice: json['max_price'] != null ? parsePrice(json['max_price']) : null,
      hasVariants: json['has_variants'] ?? false,
      imageUrl: json['image_url'],
      description: json['description'],
      farmerId: json['farmer'],
      farmerName: json['farmer_name'] ?? 'Local Farmer',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] ?? '',
    );
  }

  String get displayPrice {
    if (minPrice != null && maxPrice != null && minPrice != maxPrice) {
      return 'K${minPrice!.toInt()} - K${maxPrice!.toInt()}';
    }
    return 'K${price.toInt()}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'category_name': categoryName,
      'unit': unit,
      'price': price,
      'min_price': minPrice,
      'max_price': maxPrice,
      'has_variants': hasVariants,
      'image_url': imageUrl,
      'description': description,
      'farmer': farmerId,
      'farmer_name': farmerName,
      'is_active': isActive,
      'created_at': createdAt,
    };
  }
}