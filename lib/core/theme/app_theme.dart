import 'package:flutter/material.dart';

class AppColors {
  // Core palette — matches website exactly
  static const Color background = Color(0xFF0A0A0A);    // Near-black
  static const Color surface = Color(0xFF141414);        // Card bg
  static const Color surfaceAlt = Color(0xFF1C1C1C);     // Slightly lighter card
  static const Color border = Color(0xFF2A2A2A);         // Subtle border
  static const Color borderBright = Color(0xFF3D3D3D);   // Brighter border
  static const Color primary = Color(0xFFC0122A);        // Crimson red
  static const Color primaryDim = Color(0xFF8B0E1E);     // Darker red
  static const Color primaryGlow = Color(0xFFE01030);    // Brighter red for glow
  static const Color textPrimary = Color(0xFFFFFFFF);    // White
  static const Color textSecondary = Color(0xFFAAAAAA);  // Grey text
  static const Color textMuted = Color(0xFF666666);      // Muted text
  static const Color textRed = Color(0xFFC0122A);        // Red text (like "glory")
}

class AppTheme {
  static const Color primaryColor = AppColors.primary;
  static const Color backgroundColor = AppColors.background;
  static const Color cardColor = AppColors.surface;

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primary,
      surface: AppColors.surface,
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Space Grotesk',
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
      ),
      iconTheme: IconThemeData(color: AppColors.primary),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Space Grotesk',
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Space Grotesk',
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Space Grotesk',
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Space Grotesk',
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -0.3,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Space Grotesk',
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Space Grotesk',
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Space Grotesk',
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        color: Colors.white,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        color: Color(0xFFCCCCCC),
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Inter',
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
        color: Colors.white,
        letterSpacing: 0.3,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 1.5,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
    ),
  );
}
