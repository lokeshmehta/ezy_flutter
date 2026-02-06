import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1E3A8A); // blue
  static const Color secondaryColor = Color(0xFFFFB347); // yellow/tealcolor
  static const Color redColor = Color(0xFFE4134A);
  static const Color textColor = Color(0xFF333333);
  
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
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: textColor),
        displayMedium: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: textColor),
        displaySmall: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: textColor),
        headlineMedium: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: textColor),
        titleLarge: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: textColor),
        titleMedium: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: textColor),
        titleSmall: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: textColor),
        bodyLarge: TextStyle(fontSize: 16.sp, color: textColor),
        bodyMedium: TextStyle(fontSize: 14.sp, color: textColor),
        bodySmall: TextStyle(fontSize: 12.sp, color: textColor),
        labelLarge: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: textColor),
        labelSmall: TextStyle(fontSize: 10.sp, letterSpacing: 0.5, color: textColor),
      ),
    );
  }
}
