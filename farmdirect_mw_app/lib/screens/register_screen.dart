import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  String? _selectedArea;

  final List<String> areas = ['Area 3','Area 6','Area 9','Area 10','Area 11','Area 12','Area 14','Area 15','Area 18','Area 25','Area 43','Area 44','Area 47','Area 49','Airwing','City Centre','Kanengo'];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()), validator: (value) => value == null || value.isEmpty ? 'Please enter your first name' : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()), validator: (value) => value == null || value.isEmpty ? 'Please enter your last name' : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()), keyboardType: TextInputType.phone, validator: (value) => value == null || value.isEmpty ? 'Please enter your phone number' : null),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Delivery Area', border: OutlineInputBorder()),
                    value: _selectedArea,
                    items: areas.map((area) => DropdownMenuItem(value: area, child: Text(area))).toList(),
                    onChanged: (value) => setState(() => _selectedArea = value),
                    validator: (value) => value == null ? 'Please select your area' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock), suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)), border: const OutlineInputBorder()), obscureText: _obscurePassword, validator: (value) { if (value == null || value.isEmpty) return 'Please enter a password'; if (value.length < 8) return 'Password must be at least 8 characters'; return null; }),
                  const SizedBox(height: 16),
                  TextFormField(controller: _confirmPasswordController, decoration: const InputDecoration(labelText: 'Confirm Password', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()), obscureText: true, validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null),
                  const SizedBox(height: 24),
                  SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        final success = await authProvider.register(phone: _phoneController.text, firstName: _firstNameController.text, lastName: _lastNameController.text, password: _passwordController.text, area: _selectedArea);
                        if (success && mounted) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen())); } else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration failed'), backgroundColor: Colors.red)); }
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: authProvider.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Register', style: TextStyle(fontSize: 18, color: Colors.white)),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
