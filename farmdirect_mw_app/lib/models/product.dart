class Product {
  final int id;
  final String name;
  final String? category;
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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'],
      categoryName: json['category_name'] ?? '',
      unit: json['unit'] ?? 'kg',
      price: (json['price'] ?? 0).toDouble(),
      minPrice: json['min_price']?.toDouble(),
      maxPrice: json['max_price']?.toDouble(),
      hasVariants: json['has_variants'] ?? false,
      imageUrl: json['image_url'],
      description: json['description'],
      farmerId: json['farmer'],
      farmerName: json['farmer_name'] ?? 'Unknown Farmer',
      isActive: json['is_active'] ?? true,
    );
  }

  String get displayPrice {
    if (minPrice != null && maxPrice != null && minPrice != maxPrice) {
      return 'K${minPrice!.toInt()} - K${maxPrice!.toInt()}';
    }
    return 'K${price.toInt()}';
  }
}
