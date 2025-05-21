import 'package:flutter/material.dart';
import 'package:frontend/huudas/home_page.dart';
import 'package:frontend/huudas/login.dart';
import 'package:frontend/huudas/register.dart';
import 'package:frontend/huudas/profile.dart';
import 'package:frontend/huudas/test_screen.dart';
import 'package:frontend/huudas/cart.dart';
import 'package:frontend/huudas/intro_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'User App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const IntroScreen(), // 🚀 Шууд HomePage руу орох
      routes: {
         '/introScreen': (context) => const IntroScreen(), 
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/profile': (context) => const ProfilePage(),
        '/test': (context) => const TestScreen(),
        '/cart': (context) => const CartPage(),

      },
    );
  }
}
