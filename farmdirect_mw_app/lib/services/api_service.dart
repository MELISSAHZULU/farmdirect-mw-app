import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/order.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
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

  // ============ AUTH ============

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
      return jsonDecode(response.body);
    } catch (e) {
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
      return jsonDecode(response.body);
    } catch (e) {
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

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          return data.map((item) {
            // Parse string prices to double
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
        return [];
      }
    } catch (e) {
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
      // Parse string prices to double
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

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          return data.map((item) => Order.fromJson(item)).toList();
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> createOrder({
    required String deliveryArea,
    required String deliveryAddress,
    required String deliveryDate,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/create/'),
        headers: headers,
        body: jsonEncode({
          'delivery_area': deliveryArea,
          'delivery_address': deliveryAddress,
          'delivery_date': deliveryDate,
          'payment_method': paymentMethod,
          'items': items,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }
}