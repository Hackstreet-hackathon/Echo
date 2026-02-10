import 'package:flutter/material.dart';

/// ECHO color palette - Teal/Blue primary with black theme
class AppColors {
  AppColors._();

  // Primary - Teal/Blue
  static const Color primary = Color(0xFF00897B);
  static const Color primaryLight = Color(0xFF4DB6AC);
  static const Color primaryDark = Color(0xFF00695C);

  // Accent
  static const Color accent = Color(0xFF26A69A);
  static const Color accentLight = Color(0xFF80CBC4);

  // Dark theme base
  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color cardDark = Color(0xFF21262D);
  static const Color cardElevatedDark = Color(0xFF30363D);

  // Light theme base (for light mode support)
  static const Color backgroundLight = Color(0xFFF6F8FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimaryDark = Color(0xFFE6EDF3);
  static const Color textSecondaryDark = Color(0xFF8B949E);
  static const Color textPrimaryLight = Color(0xFF24292F);
  static const Color textSecondaryLight = Color(0xFF57606A);

  // Status
  static const Color success = Color(0xFF3FB950);
  static const Color warning = Color(0xFFD29922);
  static const Color error = Color(0xFFF85149);
  static const Color info = Color(0xFF58A6FF);

  // Accessibility - High contrast
  static const Color highContrastBorder = Color(0xFFFFFFFF);
  static const Color pwdBadge = Color(0xFFF85149);
}
