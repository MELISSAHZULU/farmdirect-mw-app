// lib/services/api_service.dart
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

      print('📡 Products Status: ${response.statusCode}');
      print('📝 Products Response: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        
        // Check if data is a list
        if (data is List) {
          print('✅ Products list length: ${data.length}');
          return data.map((item) => Product.fromJson(item)).toList();
        } else {
          print('❌ Response is not a list: ${data.runtimeType}');
          return [];
        }
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
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product');
    }
  }

  // ============ ORDERS ============

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