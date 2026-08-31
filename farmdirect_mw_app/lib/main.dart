import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/orders_screen.dart';  
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'FarmDirect MW',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF2E7D32),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2E7D32),
            foregroundColor: Colors.white,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: Color(0xFF2E7D32),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) {
            final authProvider = Provider.of<AuthProvider>(context);
            if (authProvider.isAuthenticated) {
              return const HomeScreen();
            }
            return const SplashScreen();
          },
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/search': (context) => const SearchScreen(),
          '/product-detail': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as int;
            return ProductDetailScreen(productId: args);
          },
          '/cart': (context) => const CartScreen(),
          '/orders': (context) => const OrdersScreen(),  // ← ADD THIS
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}