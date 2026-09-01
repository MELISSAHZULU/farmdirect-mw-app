// lib/providers/favorites_provider.dart
import 'package:flutter/material.dart';
import '../models/product.dart';

class FavoritesProvider extends ChangeNotifier {
  List<Product> _favorites = [];

  List<Product> get favorites => _favorites;

  bool isFavorite(Product product) {
    return _favorites.any((p) => p.id == product.id);
  }

  bool isFavoriteById(int productId) {
    return _favorites.any((p) => p.id == productId);
  }

  void toggleFavorite(Product product) {
    if (isFavorite(product)) {
      _favorites.removeWhere((p) => p.id == product.id);
    } else {
      _favorites.add(product);
    }
    notifyListeners();
  }

  void addFavorite(Product product) {
    if (!isFavorite(product)) {
      _favorites.add(product);
      notifyListeners();
    }
  }

  void removeFavorite(int productId) {
    _favorites.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  void clearFavorites() {
    _favorites.clear();
    notifyListeners();
  }

  int get count => _favorites.length;
}