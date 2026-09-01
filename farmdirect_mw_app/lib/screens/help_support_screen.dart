import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  bool _isExpanded = false;
  int? _expandedIndex;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I place an order?',
      'answer': 'Browse products on the home screen, add items to your cart, then proceed to checkout. Select your delivery area, payment method, and confirm your order.',
    },
    {
      'question': 'What are the delivery days?',
      'answer': 'We deliver on Wednesdays and Thursdays. Orders close at 8 PM on Tuesday for Wednesday delivery, and 8 PM on Wednesday for Thursday delivery.',
    },
    {
      'question': 'Is there a minimum order?',
      'answer': 'Yes, the minimum order value is K20,000. This helps us ensure efficient delivery operations.',
    },
    {
      'question': 'How can I track my order?',
      'answer': 'You can track your order status in the Orders section. The status will update from "Order Placed" to "Packing", "At Gateway Mall", "Out for Delivery", and finally "Delivered".',
    },
    {
      'question': 'What payment methods do you accept?',
      'answer': 'We accept Cash on Delivery, Airtel Money, and TNM Mpamba. All payments are secure and processed through our platform.',
    },
    {
      'question': 'Can I cancel my order?',
      'answer': 'Yes, you can cancel your order before it\'s packed. Go to your Orders, select the order, and tap "Cancel Order".',
    },
    {
      'question': 'What if I receive damaged produce?',
      'answer': 'Contact our support team immediately at 0994581339 (Thom) or 0999570858 (Rose). We\'ll work with the farmer to resolve the issue.',
    },
    {
      'question': 'How does the farmer system work?',
      'answer': 'We partner with 5 local farms: Produhort Investments, GreenGold Enterprise, Rose Farms, Isidore Farms, and Mr Fresh. Each farm specializes in different produce.',
    },
  ];

  final List<Map<String, String>> _contactMethods = [
    {
      'name': 'Thom',
      'phone': '0994581339',
      'role': 'Admin',
      'icon': 'assets/icons/whatsapp.png',
    },
    {
      'name': 'Rose',
      'phone': '0999570858',
      'role': 'Admin',
      'icon': 'assets/icons/whatsapp.png',
    },
    {
      'name': 'Alice',
      'phone': '0899717545',
      'role': 'Admin',
      'icon': 'assets/icons/whatsapp.png',
    },
    {
      'name': 'Tsinde',
      'phone': '0881362908',
      'role': 'Admin',
      'icon': 'assets/icons/whatsapp.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Section
            _buildSectionHeader('Contact Us', Icons.phone),
            const SizedBox(height: 12),
            _buildContactCard(),
            const SizedBox(height: 24),

            // FAQ Section
            _buildSectionHeader('Frequently Asked Questions', Icons.help_outline),
            const SizedBox(height: 12),
            _buildFAQList(),
            const SizedBox(height: 24),

            // Send Feedback
            _buildSectionHeader('Send Feedback', Icons.feedback_outlined),
            const SizedBox(height: 12),
            _buildFeedbackCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2E7D32), size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard() {
    return Container(
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.message,
                    color: Color(0xFF2E7D32),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact Support',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Reach us via call or WhatsApp',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ..._contactMethods.map((contact) => _buildContactItem(contact)),
        ],
      ),
    );
  }

  Widget _buildContactItem(Map<String, String> contact) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green[50],
        child: Text(
          contact['name']![0],
          style: const TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        contact['name']!,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        contact['phone']!,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.call, color: Color(0xFF2E7D32)),
            onPressed: () => _makePhoneCall(contact['phone']!),
          ),
          IconButton(
            icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
            onPressed: () => _openWhatsApp(contact['phone']!),
          ),
        ],
      ),
      onTap: () => _makePhoneCall(contact['phone']!),
    );
  }

  Widget _buildFAQList() {
    return Container(
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
        children: _faqs.asMap().entries.map((entry) {
          final index = entry.key;
          final faq = entry.value;
          return Column(
            children: [
              _buildFAQItem(faq, index),
              if (index < _faqs.length - 1) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFAQItem(Map<String, String> faq, int index) {
    final isExpanded = _expandedIndex == index;

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          faq['question']!,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          isExpanded ? Icons.expand_less : Icons.expand_more,
          color: const Color(0xFF2E7D32),
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            _expandedIndex = expanded ? index : null;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq['answer']!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context) {
    final TextEditingController _feedbackController = TextEditingController();

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share your feedback',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write your feedback or suggestions here...',
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
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  if (_feedbackController.text.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for your feedback!'),
                        backgroundColor: Color(0xFF2E7D32),
                      ),
                    );
                    _feedbackController.clear();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please write your feedback first'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Send Feedback',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phone) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showErrorSnackBar('Could not make call');
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    // Format phone number for WhatsApp
    final formattedPhone = phone.replaceAll(' ', '').replaceAll('+', '');
    final whatsappUrl = 'https://wa.me/265$formattedPhone';

    final Uri launchUri = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      _showErrorSnackBar('Could not open WhatsApp');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}