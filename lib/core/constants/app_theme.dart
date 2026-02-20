import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1E3A8A); // Blue (Android 'blue')
  static const Color secondaryColor = Color(0xFFFFB347); // Orange (Android 'tealcolor'/'yellow')
  static const Color textColor = Color(0xFF333333); // Dark Grey (Android 'text_color')
  static const Color hintColor = Color(0xFFBDBDBD); // Light Grey (Android 'hint_color')

  static const Color darkGrayColor = Color(0xFF888787); // Medium Grey (Android 'darkgray_color')
  static const Color darkerGrayColor = Color(0xFF5B5A5A); // Darker Grey (Android 'darkgreycolor') - NEW
  
  static const Color blackColor = Color(0xFF000000); // Black
  static const Color white = Color(0xFFFFFFFF); // White
  static const Color redColor = Color(0xFFE4134A); // Red
  static const Color greybtn = Color(0xFFE6E5E5); // Light Grey for buttons
  
  static const Color darkBlue = Color(0xFF1E3A8A); // Same as primary
  static const Color tealColor = Color(0xFFFFB347); // Helper alias for secondaryColor
  static const Color skyBlue = Color(0xFF0DCAF0); // Android 'skyblue'
  static const Color lightBlue = Color(0xFF0664F1); // Android 'lightblue'
  
  static const double inputRadius = 5.0;
  static const double authButtonRadius = 5.0;
  static const double productButtonRadius = 20.0;

  // Restored Constants
  static const Color orangeColor = secondaryColor;
  static const Color yellow = secondaryColor;
  static const Color darkOrange = Color(0xFFF57C00); // Estimated dark orange
  static const Color lightGrayBg = Color(0xFFF5F5F5);
  static const Color shadowBlack = Color(0x1F000000); // Black with ~12% opacity
  static const Color successGreen = Color(0xFF27AE60);
  static const Color lightGreen = Color(0xFFD4EED8);
  static const Color stepperBG = Color(0xFFF5FBFE);
  static const Color lightSecondaryColor = Color(0xFFFFD180);
  static Color redColorOpacity10 = redColor.withValues(alpha: 0.1);
  static const double arrowSize = 25.0;
  
  // Added from analysis of other files asking for inputRadius/authButtonRadius
  // If these were not in the original file, I should be careful. 
  // However, I saw them used in SignupScreen.
  // Wait, did I see them in the original config/theme/app_theme.dart?
  // Use view_file output from step 17244.
  // It DID NOT have inputRadius/authButtonRadius.
  // BUT `signup_screen.dart` used `AppTheme.inputRadius` and `AppTheme.authButtonRadius`.
  // So `config/theme/app_theme.dart` might be missing them too?
  // Let me check if `signup_screen.dart` imports `config` or `core`.
  // Step 17265 shows `signup_screen.dart` imports `core/constants/app_theme.dart`.
  // So `core` version HAS `inputRadius` etc.
  // If I overwrite `core` with `config` version (which lacks them), I will break `signup_screen.dart`.
  
  // I need to read `core/constants/app_theme.dart` first to see what extra it has.
  // Then merge.
  
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
