import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/order.dart';
import '../models/user.dart';

class ApiService {
  // ============ USE YOUR RENDER URL ============
  static const String baseUrl = 'https://farmdirect-mw-app.onrender.com/api';
  
  // For local testing (comment out when deploying):
  // static const String baseUrl = 'http://localhost:8000/api';
  
  static String? _authToken;

  static void setAuthToken(String token) { _authToken = token; }
  static String? get authToken => _authToken;

  static Map<String, String> get headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // ============ AUTHENTICATION ============

  static Future<Map<String, dynamic>> register({
    required String phone,
    required String firstName,
    required String lastName,
    required String password,
    String? area,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'first_name': firstName,
          'last_name': lastName,
          'password': password,
          'area': area,
          'role': 'customer',
        }),
      );
      
      print('📡 Register Status: ${response.statusCode}');
      print('📝 Register Response: ${response.body}');
      
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Register Error: $e');
      return {'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );
      
      print('📡 Login Status: ${response.statusCode}');
      print('📝 Login Response: ${response.body}');
      
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Login Error: $e');
      return {'error': 'Network error: $e'};
    }
  }

  // ============ PRODUCTS ============

  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/'),
        headers: headers,
      );

      print('📡 Products Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          print('✅ Products list length: ${data.length}');
          return data.map((item) {
            if (item['price'] is String) {
              item['price'] = double.tryParse(item['price'] as String) ?? 0.0;
            }
            if (item['min_price'] is String) {
              item['min_price'] = double.tryParse(item['min_price'] as String);
            }
            if (item['max_price'] is String) {
              item['max_price'] = double.tryParse(item['max_price'] as String);
            }
            return Product.fromJson(item);
          }).toList();
        }
        return [];
      } else {
        print('❌ Failed to load products: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Get Products Error: $e');
      return [];
    }
  }

  static Future<Product> getProduct(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$id/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['price'] is String) {
        data['price'] = double.tryParse(data['price'] as String) ?? 0.0;
      }
      if (data['min_price'] is String) {
        data['min_price'] = double.tryParse(data['min_price'] as String);
      }
      if (data['max_price'] is String) {
        data['max_price'] = double.tryParse(data['max_price'] as String);
      }
      return Product.fromJson(data);
    } else {
      throw Exception('Failed to load product');
    }
  }

  // ============ ORDERS ============

  static Future<List<Order>> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/'),
        headers: headers,
      );

      print('📡 Get Orders Status: ${response.statusCode}');
      print('📝 Get Orders Response: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        
        List items = [];
        if (data is List) {
          items = data;
        } else if (data is Map<String, dynamic> && data.containsKey('results')) {
          items = data['results'] as List;
        } else {
          print('⚠️ Unexpected response format: ${data.runtimeType}');
          return [];
        }
        
        print('✅ Orders list length: ${items.length}');
        return items.map((item) => Order.fromJson(item)).toList();
      } else {
        print('❌ Failed to load orders: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Get Orders Error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getOrder(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$id/'),
        headers: headers,
      );

      print('📡 Get Order Status: ${response.statusCode}');
      print('📝 Get Order Response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Failed to load order: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ Get Order Error: $e');
      return {'error': 'Network error: $e'};
    }
  }

  // ============ CREATE ORDER ============

  static Future<Map<String, dynamic>> createOrder({
    required String deliveryArea,
    required String deliveryAddress,
    required String deliveryDate,
    required String paymentMethod,
    String? specialInstructions,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      String formattedDate = deliveryDate;
      if (deliveryDate.contains('T')) {
        formattedDate = deliveryDate.split('T')[0];
      }
      
      final body = {
        'delivery_area': deliveryArea,
        'delivery_address': deliveryAddress,
        'delivery_date': formattedDate,
        'payment_method': paymentMethod,
        'items': items,
      };
      
      if (specialInstructions != null && specialInstructions.isNotEmpty) {
        body['special_instructions'] = specialInstructions;
      }

      print('📦 Creating order with body: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/orders/create/'),
        headers: headers,
        body: jsonEncode(body),
      );

      print('📡 Create Order Status: ${response.statusCode}');
      print('📝 Create Order Response: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'error': 'Failed to create order: ${response.statusCode}', 
          'detail': response.body
        };
      }
    } catch (e) {
      print('❌ Create Order Error: $e');
      return {'error': 'Network error: $e'};
    }
  }

  // ============ CANCEL ORDER ============

  static Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/cancel/'),
        headers: headers,
      );

      print('📡 Cancel Order Status: ${response.statusCode}');
      print('📝 Cancel Order Response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'error': 'Failed to cancel order: ${response.statusCode}',
          'detail': response.body
        };
      }
    } catch (e) {
      print('❌ Cancel Order Error: $e');
      return {'error': 'Network error: $e'};
    }
  }

  // ============ PAYMENT ============

  static Future<Map<String, dynamic>> initiatePayment({
    required int orderId,
    required String paymentMethod,
  }) async {
    try {
      print('💳 Initiating payment for order: $orderId');

      final response = await http.post(
        Uri.parse('$baseUrl/orders/initiate-payment/'),
        headers: headers,
        body: jsonEncode({
          'order_id': orderId,
          'payment_method': paymentMethod,
        }),
      );

      print('📡 Initiate Payment Status: ${response.statusCode}');
      print('📝 Initiate Payment Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'error': 'Payment initiation failed: ${response.statusCode}',
          'detail': response.body
        };
      }
    } catch (e) {
      print('❌ Initiate Payment Error: $e');
      return {'error': 'Network error: $e'};
    }
  }

  // ============ FARMERS ============

  static Future<List<dynamic>> getFarmers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/farmers/'),
        headers: headers,
      );

      print('📡 Farmers Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print('❌ Get Farmers Error: $e');
      return [];
    }
  }

  // ============ UTILITY ============

  static void clearAuth() {
    _authToken = null;
  }

  static bool get isAuthenticated => _authToken != null;
}