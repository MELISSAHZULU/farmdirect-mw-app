import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'cash_on_delivery';
  final TextEditingController _instructionsController = TextEditingController();
  bool _isSubmitting = false;
  bool _isProcessingPayment = false;
  String? _selectedArea;

  final List<String> _deliveryAreas = [
    'Area 3', 'Area 6', 'Area 9', 'Area 10', 'Area 11', 'Area 12',
    'Area 14', 'Area 15', 'Area 18', 'Area 25', 'Area 43', 'Area 44',
    'Area 47', 'Area 49', 'Airwing', 'City Centre', 'Kanengo',
  ];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user?.area != null && _deliveryAreas.contains(user!.area)) {
      _selectedArea = user.area;
    }
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;
    final totalPrice = cartProvider.totalPrice;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isProcessingPayment
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                  ),
                  SizedBox(height: 16),
                  Text('Processing payment...'),
                  SizedBox(height: 8),
                  Text(
                    'Please complete the payment on your phone',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery Address Section
                  _buildSectionHeader('Delivery Address'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedArea,
                          decoration: const InputDecoration(
                            labelText: 'Select Delivery Area',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          items: _deliveryAreas.map((area) {
                            return DropdownMenuItem(
                              value: area,
                              child: Text(area),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedArea = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person,
                                size: 16,
                                color: Color(0xFF2E7D32),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${user?.firstName ?? 'Guest'} ${user?.lastName ?? ''}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.phone,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user?.phone ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Delivery Day Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.local_shipping,
                              color: Color(0xFF2E7D32),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Delivery Day: WEDNESDAY 12 AUG',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Delivery between 9 AM – 2 PM',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.warning_amber,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Orders close Tuesday 8 PM',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Special Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Special Instructions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _instructionsController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Leave at gate, call on arrival...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Method
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Method',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildPaymentOption(
                            value: 'cash_on_delivery',
                            title: 'Cash on Delivery',
                            subtitle: 'Pay when delivered',
                            icon: Icons.money,
                            isPopular: true,
                          ),
                          const Divider(height: 1),
                          _buildPaymentOption(
                            value: 'airtel_money',
                            title: 'Airtel Money',
                            subtitle: 'Airtel +265',
                            icon: Icons.phone_android,
                            isPopular: false,
                          ),
                          const Divider(height: 1),
                          _buildPaymentOption(
                            value: 'tnm_mpamba',
                            title: 'TNM Mpamba',
                            subtitle: 'TNM +265',
                            icon: Icons.phone_iphone,
                            isPopular: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Order Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal (${cartProvider.itemCount} items)',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text('K${cartProvider.totalPrice.toInt()}'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Delivery',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const Text(
                              'FREE',
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'K${cartProvider.totalPrice.toInt()}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Place Order Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSubmitting || _selectedArea == null
                          ? null
                          : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'PLACE ORDER',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1B5E20),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isPopular,
  }) {
    final isSelected = _selectedPaymentMethod == value;

    return RadioListTile<String>(
      value: value,
      groupValue: _selectedPaymentMethod,
      onChanged: (val) {
        setState(() {
          _selectedPaymentMethod = val!;
        });
      },
      title: Row(
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[700],
            ),
          ),
          if (isPopular)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'POPULAR',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[500],
        ),
      ),
      activeColor: const Color(0xFF2E7D32),
    );
  }

  Future<void> _placeOrder() async {
    if (_selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery area'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final user = Provider.of<AuthProvider>(context, listen: false).user;

      if (cartProvider.items.isEmpty) {
        throw Exception('Your cart is empty');
      }

      final orderItems = cartProvider.items.map((item) {
        return {
          'product': item.product.id,
          'farmer': item.product.farmerId ?? 1,
          'quantity': item.quantity,
          'unit_price': item.product.price,
        };
      }).toList();

      final instructions = _instructionsController.text.trim();

      // Create order in backend
      final orderResponse = await ApiService.createOrder(
        deliveryArea: _selectedArea!,
        deliveryAddress: _selectedArea!,
        deliveryDate: DateTime.now().toIso8601String().split('T')[0],
        paymentMethod: _selectedPaymentMethod,
        specialInstructions: instructions.isNotEmpty ? instructions : null,
        items: orderItems,
      );

      print('📦 Full Order Response: $orderResponse');

      if (orderResponse.containsKey('error')) {
        throw Exception(orderResponse['error']);
      }

      // Get order ID - try different possible keys
      int? orderId = orderResponse['id'];
      
      // If id is not found, try to get it from the data
      if (orderId == null && orderResponse.containsKey('data')) {
        final data = orderResponse['data'];
        if (data is Map<String, dynamic>) {
          orderId = data['id'];
        }
      }

      print('📦 Order ID: $orderId');

      // If Cash on Delivery, we're done
      if (_selectedPaymentMethod == 'cash_on_delivery') {
        cartProvider.clearCart();
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Order placed successfully!'),
              backgroundColor: Color(0xFF2E7D32),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => false);
        }
        return;
      }

      // For digital payments, we need the order ID
      if (orderId == null) {
        // Try to get order number as fallback
        final orderNumber = orderResponse['order_number'];
        if (orderNumber != null) {
          // Could try to fetch the order by number
          print('⚠️ No "id" in response, but found order_number: $orderNumber');
          throw Exception('Order created but ID not returned. Please check your orders.');
        } else {
          print('⚠️ No "id" or "order_number" in response: $orderResponse');
          throw Exception('Order ID not returned from server');
        }
      }

      await _initiatePayment(orderId, cartProvider);

    } catch (e) {
      print('❌ Place Order Error: $e');
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to place order: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _initiatePayment(int orderId, CartProvider cartProvider) async {
    setState(() {
      _isProcessingPayment = true;
      _isSubmitting = false;
    });

    try {
      print('💳 Initiating payment for order: $orderId');
      
      final response = await ApiService.initiatePayment(
        orderId: orderId,
        paymentMethod: _selectedPaymentMethod,
      );

      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }

      final paymentUrl = response['payment_url'];

      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        cartProvider.clearCart();
        
        if (mounted) {
          setState(() => _isProcessingPayment = false);
          
          // Open payment URL in browser
          final uri = Uri.parse(paymentUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            // Navigate to orders after payment
            Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => false);
          } else {
            throw Exception('Could not open payment page');
          }
        }
      } else {
        throw Exception('No payment URL received from server');
      }

    } catch (e) {
      print('❌ Payment initiation error: $e');
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Payment error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}