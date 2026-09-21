import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String _paymentMethod = 'cash_on_delivery';
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
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  Text('Opening payment page...'),
                  SizedBox(height: 8),
                  Text('Complete your payment in the browser',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery Address
                  _buildSectionHeader('Delivery Address'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(),
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
                          items: _deliveryAreas
                              .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedArea = v),
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
                              const Icon(Icons.person, size: 16, color: Color(0xFF2E7D32)),
                              const SizedBox(width: 8),
                              Text('${user?.firstName ?? 'Guest'} ${user?.lastName ?? ''}',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700])),
                              const Spacer(),
                              const Icon(Icons.phone, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(user?.phone ?? '',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Delivery Day
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.local_shipping, color: Color(0xFF2E7D32)),
                          SizedBox(width: 8),
                          Text('Delivery Day: WEDNESDAY 12 AUG',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text('Delivery between 9 AM – 2 PM',
                              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text('Orders close Tuesday 8 PM',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w500)),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Special Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Special Instructions',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _instructionsController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Leave at gate, call on arrival...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF2E7D32))),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Method — TWO OPTIONS ONLY
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Payment Method',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 12),
                        _paymentOption(
                          value: 'cash_on_delivery',
                          title: 'Cash on Delivery',
                          subtitle: 'Pay when delivered',
                          icon: Icons.payments_outlined,
                        ),
                        _paymentOption(
                          value: 'paychangu',
                          title: 'Pay Online',
                          subtitle: 'Airtel Money, TNM Mpamba, card or bank',
                          icon: Icons.lock_outline,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Order Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Order Summary',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Subtotal (${cartProvider.itemCount} items)',
                              style: TextStyle(color: Colors.grey[600])),
                          Text('K${cartProvider.totalPrice.toInt()}'),
                        ]),
                        const SizedBox(height: 4),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Delivery', style: TextStyle(color: Colors.grey[600])),
                          const Text('FREE',
                              style: TextStyle(
                                  color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                        ]),
                        const Divider(height: 16),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('Total',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('K${cartProvider.totalPrice.toInt()}',
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32))),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Place Order
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSubmitting || _selectedArea == null ? null : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape:
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('PLACE ORDER',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      );

  Widget _buildSectionHeader(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)));
  }

  Widget _paymentOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _paymentMethod == value;
    final color = selected ? const Color(0xFF2E7D32) : Colors.grey;
    return InkWell(
      onTap: () => setState(() => _paymentMethod = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  // ============ PLACE ORDER ============
  Future<void> _placeOrder() async {
    if (_selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a delivery area'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

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

      final orderResponse = await ApiService.createOrder(
        deliveryArea: _selectedArea!,
        deliveryAddress: _selectedArea!,
        deliveryDate: DateTime.now().toIso8601String().split('T')[0],
        paymentMethod: _paymentMethod,
        specialInstructions: instructions.isNotEmpty ? instructions : null,
        items: orderItems,
      );

      print('[ORDER] Response: $orderResponse');

      if (orderResponse.containsKey('error')) {
        throw Exception(orderResponse['error']);
      }

      // Extract order ID
      int? orderId = orderResponse['id'];
      if (orderId == null && orderResponse.containsKey('data')) {
        final data = orderResponse['data'];
        if (data is Map<String, dynamic>) orderId = data['id'];
      }

      if (orderId == null) {
        throw Exception('Order ID not returned');
      }

      // Cash on Delivery — done
      if (_paymentMethod == 'cash_on_delivery') {
        cartProvider.clearCart();
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('🎉 Order placed successfully!'),
                backgroundColor: Color(0xFF2E7D32),
                duration: Duration(seconds: 2)),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => false);
        }
        return;
      }

      // Pay Online (PayChangu)
      await _initiatePayment(orderId, cartProvider);
    } catch (e) {
      print('[ORDER] Error: $e');
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('❌ Failed to place order: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  // ============ INITIATE PAYCHANGU PAYMENT ============
  Future<void> _initiatePayment(int orderId, CartProvider cartProvider) async {
    setState(() {
      _isProcessingPayment = true;
      _isSubmitting = false;
    });

    try {
      final res = await ApiService.initiatePayment(
        orderId: orderId,
        paymentMethod: 'paychangu',
      );

      print('[PAY] Response: $res');

      if (res.containsKey('error')) throw Exception(res['error']);

      final paymentUrl = res['payment_url'];
      if (paymentUrl == null || (paymentUrl as String).isEmpty) {
        throw Exception('No payment URL received');
      }

      cartProvider.clearCart();

      if (mounted) {
        setState(() => _isProcessingPayment = false);
        final ok = await launchUrl(
          Uri.parse(paymentUrl),
          mode: LaunchMode.externalApplication,
        );
        if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open the payment page')),
          );
        }
        Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => false);
      }
    } catch (e) {
      print('[PAY] Error: $e');
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('❌ Payment error: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5)),
        );
      }
    }
  }
}