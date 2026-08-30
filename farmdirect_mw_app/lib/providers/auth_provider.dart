import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  final _storage = const FlutterSecureStorage();

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null && _token != null;

  AuthProvider() { _loadFromStorage(); }

  Future<void> _loadFromStorage() async {
    final token = await _storage.read(key: 'token');
    final userData = await _storage.read(key: 'user');
    if (token != null && userData != null) {
      _token = token;
      ApiService.setAuthToken(token);
      _user = User.fromJson(jsonDecode(userData));
      notifyListeners();
    }
  }

  Future<bool> login(String phone, String password) async {
    _isLoading = true; notifyListeners();
    try {
      final response = await ApiService.login(phone: phone, password: password);
      if (response.containsKey('access')) {
        _token = response['access'];
        ApiService.setAuthToken(_token!);
        _user = User.fromJson(response['user']);
        await _storage.write(key: 'token', value: _token);
        await _storage.write(key: 'user', value: jsonEncode(_user!.toJson()));
        _isLoading = false; notifyListeners();
        return true;
      } else {
        _isLoading = false; notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false; notifyListeners();
      return false;
    }
  }

  Future<bool> register({required String phone, required String firstName, required String lastName, required String password, String? area}) async {
    _isLoading = true; notifyListeners();
    try {
      final response = await ApiService.register(
        phone: phone, firstName: firstName, lastName: lastName, password: password, area: area
      );
      if (response.containsKey('access')) {
        _token = response['access'];
        ApiService.setAuthToken(_token!);
        _user = User.fromJson(response['user']);
        await _storage.write(key: 'token', value: _token);
        await _storage.write(key: 'user', value: jsonEncode(_user!.toJson()));
        _isLoading = false; notifyListeners();
        return true;
      } else {
        _isLoading = false; notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false; notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null; _token = null;
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'user');
    notifyListeners();
  }
}
