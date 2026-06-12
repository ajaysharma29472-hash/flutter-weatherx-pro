import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color accent = Color(0xFF00BCD4);
  static const Color bgDark = Color(0xFF0A0E21);
  static const Color cardDark = Color(0xFF1D2747);
  static const Color cardDark2 = Color(0xFF162032);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted = Color(0xFF607D8B);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color gradStart = Color(0xFF1565C0);
  static const Color gradEnd = Color(0xFF0A0E21);

  static LinearGradient get bgGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradStart, gradEnd],
      );

  static LinearGradient get cardGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1D2747), Color(0xFF162032)],
      );

  static LinearGradient get sunnyGradient => const LinearGradient(
        colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
      );

  static LinearGradient get rainyGradient => const LinearGradient(
        colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
      );

  static LinearGradient get cloudyGradient => const LinearGradient(
        colors: [Color(0xFF455A64), Color(0xFF263238)],
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: accent,
          surface: cardDark,
          error: error,
        ),
        scaffoldBackgroundColor: bgDark,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
          displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
          bodySmall: TextStyle(color: textMuted),
          labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardDark,
          hintStyle: const TextStyle(color: textMuted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        cardTheme: CardTheme(
          color: cardDark,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: accent,
          surface: Color(0xFFF5F7FA),
          error: error,
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F4FF),
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
          iconTheme: IconThemeData(color: Color(0xFF1A1A2E)),
        ),
      );

  static Color aqiColor(int aqi) {
    switch (aqi) {
      case 1:
        return success;
      case 2:
        return const Color(0xFF8BC34A);
      case 3:
        return warning;
      case 4:
        return const Color(0xFFFF7043);
      case 5:
        return error;
      default:
        return textMuted;
    }
  }

  static String aqiLabel(int aqi) {
    switch (aqi) {
      case 1:
        return 'Good';
      case 2:
        return 'Fair';
      case 3:
        return 'Moderate';
      case 4:
        return 'Poor';
      case 5:
        return 'Very Poor';
      default:
        return 'Unknown';
    }
  }
}
