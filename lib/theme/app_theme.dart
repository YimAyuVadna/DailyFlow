import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors (Shared across themes)
  static const Color accentNeonGreen = Color(0xFF00FFB2);
  static const Color accentMagenta = Color(0xFFFF2E93);
  static const Color accentOrange = Color(0xFFFF8A00);
  static const Color accentBlue = Color(0xFF448AFF);
  static const Color successGreen = Color(0xFF00E676);
  static const Color warningAmber = Color(0xFFFFB300);

  // Dark Theme Colors
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF14141C);
  static const Color surfaceLight = Color(0xFF1C1C26);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0AB);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F5F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceLight = Color(0xFFB0B0B0); // Much darker grey for empty cells
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF222222); // Almost black for secondary text

  // Surface helper for getting the right surface color based on theme
  static Color getSurface(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? surface : lightSurface;

  static Color getSurfaceLight(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? surfaceLight : lightSurfaceLight;

  static Color getTextSecondary(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? textSecondary : lightTextSecondary;

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accentNeonGreen,
        secondary: accentMagenta,
        surface: surface,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.bold),
        displayMedium: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 28),
        titleLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w700),
        bodyLarge: GoogleFonts.inter(color: textPrimary),
        bodyMedium: const TextStyle(color: textSecondary, fontSize: 14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: accentBlue,
        secondary: accentMagenta,
        surface: lightSurface,
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData(brightness: Brightness.light).textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.inter(color: lightTextPrimary, fontWeight: FontWeight.bold),
        displayMedium: const TextStyle(color: lightTextPrimary, fontWeight: FontWeight.bold, fontSize: 28),
        titleLarge: GoogleFonts.inter(color: lightTextPrimary, fontWeight: FontWeight.w700),
        bodyLarge: GoogleFonts.inter(color: lightTextPrimary),
        bodyMedium: const TextStyle(color: lightTextSecondary, fontSize: 14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(color: lightTextPrimary, fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }
}
