import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens ported directly from the RF TV web mockup so the Flutter
/// app matches it pixel-for-pixel in spirit: same palette, same two-font
/// system (Sora for display type, Inter for body copy).
class AppColors {
  static const navy = Color(0xFF0A2E44);
  static const navy2 = Color(0xFF0B3852);
  static const ocean = Color(0xFF0E5A82);
  static const sky = Color(0xFF1FA6DB);
  static const cyan = Color(0xFF6FE0FF);
  static const ember = Color(0xFFE8481D);
  static const amber = Color(0xFFFF8A3D);
  static const cream = Color(0xFFFBF7F1);
  static const cream2 = Color(0xFFF3ECE1);
  static const ink = Color(0xFF122633);
  static const slate = Color(0xFF64707D);
  static const slateLight = Color(0xFF93A0AC);
  static const line = Color(0x1A0A2E44);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy, ocean, sky],
  );

  static const flameGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ember, amber],
  );

  static const cyanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sky, cyan],
  );
}

class AppText {
  static TextStyle sora({
    double size = 14,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.navy,
    double? letterSpacing,
  }) =>
      GoogleFonts.sora(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  static TextStyle inter({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double? letterSpacing,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.cream,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.sky,
      primary: AppColors.navy,
      secondary: AppColors.sky,
      surface: Colors.white,
    ),
    fontFamily: GoogleFonts.inter().fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.cream,
      elevation: 0,
      foregroundColor: AppColors.navy,
      titleTextStyle: AppText.sora(size: 16),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.sky, width: 1.5),
      ),
    ),
  );
}
