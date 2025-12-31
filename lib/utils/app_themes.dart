import 'package:flutter/material.dart';

/// StreamNet TV Custom Theme
///
/// Based on the provided CSS theme with dark grays and gold accent color.
class AppThemes {
  // Primary Colors from CSS theme
  static const Color primaryGold = Color(0xFFE5A00D);
  static const Color primaryGoldHover = Color(0xFFFFC107);
  static const Color buttonColor = Color(0xFFCC7B19);
  static const Color buttonColorHover = Color(0xFFE59029);

  // Background Colors
  static const Color mainBgDark = Color(0xFF000000);
  static const Color modalBgColor = Color(0xFF282828);
  static const Color modalHeaderColor = Color(0xFF323232);
  static const Color dropDownMenuBg = Color(0xFF191A1C);

  // Surface Colors
  static const Color surfaceDark1 = Color(0xFF2F2F2F);
  static const Color surfaceDark2 = Color(0xFF3F3F3F);
  static const Color surfaceDark3 = Color(0xFF4C4C4C);
  static const Color surfaceDark4 = Color(0xFF3A3A3A);

  // Text Colors
  static const Color textPrimary = Color(0xFFDDDDDD);
  static const Color textHover = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF999999);
  static const Color buttonText = Color(0xFFEEEEEE);

  // Accent Color (RGB for opacity variations)
  static const int accentR = 229;
  static const int accentG = 160;
  static const int accentB = 13;

  /// Dark Theme - Primary theme for StreamNet TV
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        onPrimary: Colors.black,
        secondary: buttonColor,
        onSecondary: buttonText,
        surface: modalBgColor,
        onSurface: textPrimary,
        error: Colors.redAccent,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: mainBgDark,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: modalHeaderColor,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Cards
      cardTheme: CardTheme(
        color: modalBgColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: buttonText,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryGold),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark1,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: surfaceDark3, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
        prefixIconColor: textMuted,
        suffixIconColor: textMuted,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: modalHeaderColor,
        selectedItemColor: primaryGold,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Navigation Rail (Desktop)
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: modalHeaderColor,
        selectedIconTheme: IconThemeData(color: primaryGold),
        unselectedIconTheme: IconThemeData(color: textMuted),
        selectedLabelTextStyle: TextStyle(color: primaryGold),
        unselectedLabelTextStyle: TextStyle(color: textMuted),
      ),

      // Divider
      dividerTheme: const DividerThemeData(color: surfaceDark3, thickness: 1),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryGold,
        circularTrackColor: surfaceDark3,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceDark2,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: modalBgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(color: textPrimary, fontSize: 16),
      ),

      // List Tile
      listTileTheme: const ListTileThemeData(
        iconColor: textMuted,
        textColor: textPrimary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // Icon
      iconTheme: const IconThemeData(color: textMuted, size: 24),

      // Text Theme - Use inherit: true (default) for Material Design compatibility
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textPrimary),
        bodySmall: TextStyle(color: textMuted),
        labelLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(color: textMuted),
        labelSmall: TextStyle(color: textMuted),
      ),
    );
  }

  /// Light Theme - Alternative theme (optional)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryGold,
        onPrimary: Colors.black,
        secondary: buttonColor,
        surface: Colors.grey.shade100,
      ),
    );
  }

  /// Gradient for backgrounds
  static BoxDecoration get mainBackgroundDecoration {
    return const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.bottomLeft,
        radius: 1.5,
        colors: [surfaceDark1, mainBgDark],
      ),
    );
  }

  /// Splash screen gradient
  static BoxDecoration get splashGradient {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
      ),
    );
  }
}
