import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// ECHO theme configuration - Material 3 with black theme
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => dark(highContrast: false);

  static ThemeData dark({bool highContrast = false}) {
    final background = highContrast ? Colors.black : AppColors.backgroundDark;
    final surface = highContrast ? Colors.black : AppColors.surfaceDark;
    final card = highContrast ? const Color(0xFF161B22) : AppColors.cardDark;
    final text = highContrast ? Colors.white : AppColors.textPrimaryDark;
    final accent = highContrast ? Colors.white : AppColors.primary;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: accent,
        onPrimary: highContrast ? Colors.black : Colors.white,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.accent,
        onSecondary: Colors.black,
        surface: surface,
        onSurface: text,
        surfaceContainerHighest: AppColors.cardElevatedDark,
        error: AppColors.error,
        onError: Colors.white,
        outline: highContrast ? Colors.white : AppColors.textSecondaryDark,
      ),
      scaffoldBackgroundColor: background,
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: highContrast ? const BorderSide(color: Colors.white, width: 2) : BorderSide.none,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.backgroundDark,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryDark,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardElevatedDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: card,
        selectedColor: accent,
        labelStyle: TextStyle(color: text),
      ),
    );
  }

  static ThemeData get lightTheme => light(highContrast: false);

  static ThemeData light({bool highContrast = false}) {
    final background = highContrast ? Colors.white : AppColors.backgroundLight;
    final text = highContrast ? Colors.black : AppColors.textPrimaryLight;
    final accent = highContrast ? Colors.black : AppColors.primary;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: accent,
        onPrimary: highContrast ? Colors.white : Colors.white,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.accent,
        onSecondary: Colors.black,
        surface: background,
        onSurface: text,
        surfaceContainerHighest: AppColors.cardLight,
        error: AppColors.error,
        onError: Colors.white,
        outline: highContrast ? Colors.black : AppColors.textSecondaryLight,
      ),
      scaffoldBackgroundColor: background,
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
      ),
    );
  }
}
