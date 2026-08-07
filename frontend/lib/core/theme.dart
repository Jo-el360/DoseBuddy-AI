import 'package:flutter/material.dart';

class DoseBuddyTheme {
  // High contrast color palette tuned for elderly readability
  static const Color primaryTeal = Color(0xFF00695C);
  static const Color accentAmber = Color(0xFFFF8F00);
  static const Color alertRed = Color(0xFFC62828);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color backgroundLight = Color(0xFFF7F9FA);
  static const Color cardSurface = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);

  static ThemeData get elderlyTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        secondary: accentAmber,
        error: alertRed,
        background: backgroundLight,
        surface: cardSurface,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textDark),
        headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textDark),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textDark),
        bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: textDark, height: 1.4),
        bodyMedium: TextStyle(fontSize: 16, color: textDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(60), // Extra large tap target for elderly hands
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          elevation: 4,
        ),
      ),
      cardTheme: CardTheme(
        color: cardSurface,
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
        ),
      ),
    );
  }
}
