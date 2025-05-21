import 'package:flutter/material.dart';
import 'welcome.dart';
import 'login.dart';
import 'register.dart';
import 'dashboard.dart';
import 'product_home.dart';
import 'settings.dart';
import 'profile.dart';
import 'cart.dart';
import 'register_screen.dart';
import 'material_card.dart';
import 'payment_page.dart';
import 'admin_dashboard.dart';
import 'operator_dashboard.dart';
import 'admin_products_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDark = false;

  void toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Пасадын материал',
      theme: _isDark
          ? ThemeData.dark()
          : ThemeData(
              useMaterial3: true,
              primarySwatch: Colors.teal,
              scaffoldBackgroundColor: const Color(0xFFF9F9F9),
            ),
      home: const WelcomeScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => DashboardScreen(toggleTheme: toggleTheme),
        '/products': (context) => const ProductHomePage(),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => const SettingsPage(),
        '/cart': (context) => const CartPage(),
        '/admin': (context) => const AdminDashboard(),
        '/operatorDashboard': (context) => const OperatorDashboard(),
        '/admin/products': (context) => const AdminProductsPage(),
      },
    );
  }
}