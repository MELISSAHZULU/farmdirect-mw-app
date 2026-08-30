import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ApiService.getProducts();
      setState(() { _products = products; _isLoading = false; });
    } catch (e) {
      setState(() { _error = 'Failed to load products: $e'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('FarmDirect MW'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () async { await authProvider.logout(); if (mounted) { Navigator.pushReplacementNamed(context, '/login'); } }),
        ],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _error.isNotEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(_error), ElevatedButton(onPressed: _loadProducts, child: const Text('Retry'))])) : RefreshIndicator(
        onRefresh: _loadProducts,
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.8),
          itemCount: _products.length,
          itemBuilder: (context, index) {
            final product = _products[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Container(color: Colors.grey[200], child: Center(child: Text(product.name[0].toUpperCase())))),
                Padding(padding: const EdgeInsets.all(8.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('🌱 ${product.farmerName}', style: TextStyle(fontSize: 11, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(product.displayPrice, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E7D32))),
                    Container(decoration: BoxDecoration(color: const Color(0xFF2E7D32), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.add, color: Colors.white, size: 20)),
                  ]),
                ])),
              ]),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF2E7D32),
        items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'), BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'), BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'), BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')],
        currentIndex: 0,
      ),
    );
  }
}
