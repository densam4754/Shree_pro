import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color primaryBlue = Color(0xFF2196F3); // Blue
  static const Color halfDeepBlue = Color(0xFF1565C0); // Half-deep blue
  static const Color deepBlue = Color(0xFF0D47A1); // Deep blue
  static const Color lightBlue = Color(0xFF42A5F5); // Lighter blue
  static const Color mediumBlue = Color(0xFF1E88E5); // Medium blue
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFDFEFF), Color(0xFF64B5F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [primaryBlue, halfDeepBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'SFPRODISPLAY',
      
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        secondary: halfDeepBlue,
        surface: white,
        background: grey100,
        error: Colors.red,
        onPrimary: white,
        onSecondary: white,
        onSurface: black,
        onBackground: black,
        onError: white,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: black,
        titleTextStyle: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: black,
        ),
      ),

      // Scaffold Theme
      scaffoldBackgroundColor: const Color.fromARGB(255, 248, 242, 242),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: white,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'SFPRODISPLAY',
          color: grey600,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'SFPRODISPLAY',
          color: grey400,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'SFPRODISPLAY',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          textStyle: const TextStyle(
            fontFamily: 'SFPRODISPLAY',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: black,
        ),
        displayMedium: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: black,
        ),
        displaySmall: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: black,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: black,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: black,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: black,
        ),
        titleLarge: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: black,
        ),
        titleMedium: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: black,
        ),
        titleSmall: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: black,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: black,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: black,
        ),
        bodySmall: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: grey600,
        ),
        labelLarge: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: black,
        ),
        labelMedium: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: grey600,
        ),
        labelSmall: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: grey500,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: grey700,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: grey300,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Dark Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'SFPRODISPLAY',
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: halfDeepBlue,
        surface: grey800,
        background: grey900,
        error: Colors.red,
        onPrimary: white,
        onSecondary: white,
        onSurface: white,
        onBackground: white,
        onError: white,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: white,
        titleTextStyle: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: white,
        ),
      ),

      // Scaffold Theme
      scaffoldBackgroundColor: grey900,

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: grey800,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: grey800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: grey600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: grey600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'SFPRODISPLAY',
          color: grey400,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'SFPRODISPLAY',
          color: grey500,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'SFPRODISPLAY',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          textStyle: const TextStyle(
            fontFamily: 'SFPRODISPLAY',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: white,
        ),
        displayMedium: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: white,
        ),
        displaySmall: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: white,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: white,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: white,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: white,
        ),
        titleLarge: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: white,
        ),
        titleMedium: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: white,
        ),
        titleSmall: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: white,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: white,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: white,
        ),
        bodySmall: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: grey400,
        ),
        labelLarge: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: white,
        ),
        labelMedium: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: grey400,
        ),
        labelSmall: TextStyle(
          fontFamily: 'SFPRODISPLAY',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: grey500,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: grey300,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: grey700,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

