import 'package:flutter/material.dart';

/// App color palette extracted directly from the MediCare design system.
abstract final class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF0B8F71);
  static const Color primaryDark = Color(0xFF076B58);
  static const Color primaryLight = Color(0xFFE8F6F2);
  static const Color primaryGradientStart = Color(0xFF0EAA87);
  static const Color primaryGradientEnd = Color(0xFF0B8F71);

  // Neutral & background tones
  static const Color navy = Color(0xFF10213F);
  static const Color navyLight = Color(0xFF1E3A5F);
  static const Color background = Color(0xFFF8FBFB);
  static const Color surface = Colors.white;
  static const Color card = Colors.white;
  static const Color border = Color(0xFFE8EEF2);
  static const Color borderSubtle = Color(0xFFF1F5F8);

  // Text hierarchy
  static const Color textPrimary = Color(0xFF10213F);
  static const Color textSecondary = Color(0xFF6B7A90);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textLight = Colors.white;

  // Status & Feedback colors
  static const Color success = Color(0xFF21A875);
  static const Color successLight = Color(0xFFEAF8F2);
  static const Color warning = Color(0xFFF39A33);
  static const Color warningLight = Color(0xFFFEF6EB);
  static const Color danger = Color(0xFFEF4B55);
  static const Color dangerLight = Color(0xFFFDF1F2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFEFF6FF);

  // Pill / Form category colors
  static const Color chipBackground = Color(0xFFF1F5F9);
  static const Color chipSelected = Color(0xFF0B8F71);
  static const Color chipSelectedText = Colors.white;
}
