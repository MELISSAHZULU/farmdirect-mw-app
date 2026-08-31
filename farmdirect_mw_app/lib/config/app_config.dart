// lib/config/app_config.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  // Base URL for the API
  static String get baseUrl {
    // For web (Chrome, Edge, etc.)
    if (kIsWeb) {
      // On web, use localhost or IP
      // If you're testing on the same machine:
      return 'http://localhost:8000/api';
      // If you're testing across devices, use your IP:
      // return 'http://10.199.199.249:8000/api';
    }
    
    // For Android Emulator
    if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to access host machine
      return 'http://10.0.2.2:8000/api';
    }
    
    // For iOS Simulator
    if (Platform.isIOS) {
      // iOS simulator uses localhost
      return 'http://localhost:8000/api';
    }
    
    // For physical Android/iOS device
    // Use your computer's IP address
    return 'http://10.199.199.249:8000/api';
  }
  
  // Helper to check if we're in debug mode
  static bool get isDebug {
    bool inDebug = false;
    assert(inDebug = true);
    return inDebug;
  }
  
  // Helper to get the full URL for an endpoint
  static String getEndpoint(String endpoint) {
    return '$baseUrl$endpoint';
  }
}