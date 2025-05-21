import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {
  runApp(const AutoPartsApp());
}

class AutoPartsApp extends StatelessWidget {
  const AutoPartsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auto Parts',
      theme: ThemeData(
        primaryColor: const Color(0xFF14293D), // Dark blue primary color
        scaffoldBackgroundColor: const Color(0xFF14293D),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFF89232), // Orange accent color
          secondary: const Color(0xFFF89232),
          background: const Color(0xFF14293D),
          surface: const Color(0xFF1D3953),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF14293D),
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Color(0xFFF89232),
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: const Color(0xFF1D3953),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white24),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFF89232)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF89232),
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
