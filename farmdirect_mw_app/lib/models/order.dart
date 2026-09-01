// lib/models/order.dart
class Order {
  final int id;
  final String orderNumber;
  final int customerId;
  final String deliveryArea;
  final String deliveryAddress;
  final String deliveryDate;
  final String paymentMethod;
  final String paymentStatus;
  final double totalAmount;
  final String status;
  final List<OrderItem> items;
  final String createdAt;
  final String specialInstructions; // ← ADD THIS

  Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.deliveryArea,
    required this.deliveryAddress,
    required this.deliveryDate,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.totalAmount,
    required this.status,
    required this.items,
    required this.createdAt,
    required this.specialInstructions, // ← ADD THIS
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Debug print to see what we're receiving
    print('📦 Parsing Order from JSON: $json');
    
    return Order(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      customerId: json['customer'] ?? 0,
      deliveryArea: json['delivery_area'] ?? '',
      deliveryAddress: json['delivery_address'] ?? '',
      deliveryDate: json['delivery_date'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      totalAmount: _parseDouble(json['total_amount']),
      status: json['status'] ?? 'pending',
      items: (json['items'] as List? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      createdAt: json['created_at'] ?? '',
      specialInstructions: json['special_instructions'] ?? '', // ← ADD THIS
    );
  }

  // Helper to parse double safely
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String get statusDisplay {
    final statusMap = {
      'pending': '⏳ Order Placed',
      'packing': '📦 Farmer Packing',
      'at_gateway': '🏢 At Gateway Mall',
      'out_for_delivery': '🚚 Out for Delivery',
      'delivered': '✅ Delivered',
      'cancelled': '❌ Cancelled',
    };
    return statusMap[status] ?? status;
  }

  String get statusColor {
    final colorMap = {
      'pending': '#FFA726',
      'packing': '#42A5F5',
      'at_gateway': '#AB47BC',
      'out_for_delivery': '#26C6DA',
      'delivered': '#66BB6A',
      'cancelled': '#EF5350',
    };
    return colorMap[status] ?? '#9E9E9E';
  }
}

class OrderItem {
  final int id;
  final int productId;
  final String? productName;
  final int? farmerId;
  final String? farmerName;
  final double quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItem({
    required this.id,
    required this.productId,
    this.productName,
    this.farmerId,
    this.farmerName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      productId: json['product'] ?? 0,
      productName: json['product_name'],
      farmerId: json['farmer'],
      farmerName: json['farmer_name'],
      quantity: _parseDouble(json['quantity']),
      unitPrice: _parseDouble(json['unit_price']),
      totalPrice: _parseDouble(json['total_price']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}