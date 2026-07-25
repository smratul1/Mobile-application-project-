import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFC2185B);
  static const Color gradientStart = Color(0xFFE91E8C);
  static const Color gradientEnd = Color(0xFF7B1FA2);
  static const Color accentPink = Color(0xFFE91E8C);
  static const Color background = Color(0xFFF8F9FF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color border = Color(0xFFE8D5F0);
  static const Color secondary = Color(0xFFF3E5F5);
  static const Color accent = Color(0xFF7B1FA2);
  static const Color destructive = Color(0xFFEF4444);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientH = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkCard = Color(0xFF1A1F2E);
  static const Color darkCardAlt = Color(0xFF1E2536);
  static const Color darkText = Color(0xFFE5E7EB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkBorder = Color(0xFF273141);
  static const Color darkSecondary = Color(0xFF1F2937);
  static const Color teal = Color(0xFF06B6D4);
  static const Color tealDark = Color(0xFF0891B2);
}
