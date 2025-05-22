import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF2B2D42),
    scaffoldBackgroundColor: Colors.white,
    textTheme: TextTheme(
      titleLarge: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2B2D42),
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 16,
        color: Colors.grey[600],
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.grey[800],
      ),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF2B2D42),
      size: 24,
    ),
  );
}
