import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/order.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
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

  static Future<Map<String, dynamic>> register({
    required String phone,
    required String firstName,
    required String lastName,
    required String password,
    String? area,
  }) async {
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
  }

  static Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
