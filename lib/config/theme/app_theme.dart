import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1E3A8A); // blue
  static const Color secondaryColor = Color(0xFFFFB347); // yellow/tealcolor
  static const Color redColor = Color(0xFFE4134A);
  static const Color textColor = Color(0xFF333333);
  static const Color tealColor = Color(0xFF009688);
  static const Color white = Colors.white;
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, secondary: secondaryColor),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'OpenSans'),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'OpenSans'),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'OpenSans'),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'OpenSans'),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor, fontFamily: 'OpenSans'),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor, fontFamily: 'OpenSans'),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor, fontFamily: 'OpenSans'),
        bodyLarge: TextStyle(fontSize: 16, color: textColor, fontFamily: 'OpenSans'),
        bodyMedium: TextStyle(fontSize: 14, color: textColor, fontFamily: 'OpenSans'),
        bodySmall: TextStyle(fontSize: 12, color: textColor, fontFamily: 'OpenSans'),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor, fontFamily: 'OpenSans'),
        labelSmall: TextStyle(fontSize: 10, letterSpacing: 0.5, color: textColor, fontFamily: 'OpenSans'),
      ).apply(
        fontFamily: 'OpenSans',
      ),
    );
  }
}
