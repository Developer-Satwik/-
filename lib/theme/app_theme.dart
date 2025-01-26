import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const primaryColor = Color(0xFF6C63FF);
  static const secondaryColor = Color(0xFF32D74B);
  static const accentColor = Color(0xFFFF6B6B);
  static const backgroundColor = Color(0xFF0A0E21);
  static const surfaceColor = Color(0xFF1F1F30);
  static const errorColor = Color(0xFFFF5252);
  static const warningColor = Color(0xFFFFB020);
  static const successColor = Color(0xFF4CAF50);

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4A55A2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFE94560)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0E21), Color(0xFF1F1F30)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Light Theme Colors
  static const lightPrimaryColor = Color(0xFF4A55A2);
  static const lightSecondaryColor = Color(0xFF28965A);
  static const lightAccentColor = Color(0xFFE94560);
  static const lightBackgroundColor = Color(0xFFF5F5F7);
  static const lightSurfaceColor = Color(0xFFFFFFFF);

  static const lightBackgroundGradient = LinearGradient(
    colors: [Color(0xFFF5F5F7), Color(0xFFE8E8E8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Glassmorphic Effects
  static BoxDecoration get glassDecoration => BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
      width: 2,
    ),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.1),
        Colors.white.withOpacity(0.05),
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get lightGlassDecoration => BoxDecoration(
    color: Colors.white.withOpacity(0.7),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withOpacity(0.5),
      width: 2,
    ),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.7),
        Colors.white.withOpacity(0.5),
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Responsive Typography
  static TextStyle get headingLarge => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle get headingMedium => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
  );

  static TextStyle get buttonText => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.4,
  );

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: secondaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
  );

  // Input Decoration
  static InputDecoration get inputDecoration => InputDecoration(
    filled: true,
    fillColor: Colors.white.withOpacity(0.1),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryColor),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  // High Contrast Colors
  static const highContrastDarkColors = ColorScheme.dark(
    primary: Colors.white,
    onPrimary: Colors.black,
    secondary: Colors.white,
    onSecondary: Colors.black,
    surface: Colors.black,
    onSurface: Colors.white,
    background: Colors.black,
    onBackground: Colors.white,
    error: Color(0xFFFF0000),
    onError: Colors.white,
  );

  static const highContrastLightColors = ColorScheme.light(
    primary: Colors.black,
    onPrimary: Colors.white,
    secondary: Colors.black,
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black,
    background: Colors.white,
    onBackground: Colors.black,
    error: Color(0xFFFF0000),
    onError: Colors.white,
  );

  // Responsive Decorations
  static BoxDecoration getGlassDecoration(BuildContext context, bool isDarkMode) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return BoxDecoration(
      color: Colors.white.withOpacity(isDarkMode ? 0.1 : 0.7),
      borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
      border: Border.all(
        color: Colors.white.withOpacity(isDarkMode ? 0.2 : 0.5),
        width: isSmallScreen ? 1 : 2,
      ),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(isDarkMode ? 0.1 : 0.7),
          Colors.white.withOpacity(isDarkMode ? 0.05 : 0.5),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: isSmallScreen ? 8 : 10,
          spreadRadius: 0,
          offset: Offset(0, isSmallScreen ? 2 : 4),
        ),
      ],
    );
  }

  // Responsive Padding
  static EdgeInsets getScreenPadding(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (size.width < 600) {
      return const EdgeInsets.all(16);
    } else if (size.width < 1200) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  // Theme Data
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: headingMedium.copyWith(color: Colors.white),
      toolbarHeight: 64,
    ),
    textTheme: TextTheme(
      headlineLarge: headingLarge,
      headlineMedium: headingMedium,
      bodyLarge: bodyLarge,
    ).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle,
    ),
    cardTheme: CardTheme(
      color: surfaceColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceColor,
      contentTextStyle: bodyLarge.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: lightPrimaryColor,
      secondary: lightSecondaryColor,
      surface: lightSurfaceColor,
      background: lightBackgroundColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: lightBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: headingMedium.copyWith(color: lightPrimaryColor),
      toolbarHeight: 64,
    ),
    textTheme: TextTheme(
      headlineLarge: headingLarge,
      headlineMedium: headingMedium,
      bodyLarge: bodyLarge,
    ).apply(
      bodyColor: lightPrimaryColor,
      displayColor: lightPrimaryColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle,
    ),
    cardTheme: CardTheme(
      color: lightSurfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: lightSurfaceColor,
      contentTextStyle: bodyLarge.copyWith(color: lightPrimaryColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: lightSurfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );

  // High Contrast Themes
  static ThemeData get highContrastDarkTheme => darkTheme.copyWith(
    colorScheme: highContrastDarkColors,
  );

  static ThemeData get highContrastLightTheme => lightTheme.copyWith(
    colorScheme: highContrastLightColors,
  );
}