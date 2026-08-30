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
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['order_number'] ?? '',
      customerId: json['customer'],
      deliveryArea: json['delivery_area'] ?? '',
      deliveryAddress: json['delivery_address'] ?? '',
      deliveryDate: json['delivery_date'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      createdAt: json['created_at'] ?? '',
    );
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
}

class OrderItem {
  final int id;
  final int productId;
  final double quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['product'],
      quantity: (json['quantity'] ?? 0).toDouble(),
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }
}
