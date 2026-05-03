import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors - Professional Mature (Indigo)
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Secondary Colors - Slate Gray
  static const Color secondary = Color(0xFF94A3B8);
  static const Color secondaryLight = Color(0xFFCBD5E1);
  static const Color secondaryDark = Color(0xFF64748B);

  // Accent - Blue
  static const Color accent = Color(0xFF3B82F6);
  static const Color accentLight = Color(0xFF60A5FA);
  static const Color accentDark = Color(0xFF2563EB);

  // Background - Deep Slate
  static const Color background = Color(0xFF0F172A);
  static const Color backgroundDark = Color(0xFF020617);
  static const Color backgroundLight = Color(0xFF1E293B);
  static const Color surface = Color(0xFF1E293B);
  static const Color surfaceLight = Color(0xFF334155);

  // Glass (subtle)
  static const Color glassWhite = Color(0x0DFFFFFF);
  static const Color glassPrimary = Color(0x0D6366F1);
  static const Color glassCyan = Color(0x0D3B82F6);

  // Text - Clean
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF475569);

  // Glow (subtle)
  static const Color glowPurple = Color(0xFF6366F1);
  static const Color glowCyan = Color(0xFF3B82F6);
  static const Color glowBlue = Color(0xFF60A5FA);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Gradients (subtle)
  static const List<Color> primaryGradient = [
    Color(0xFF6366F1),
    Color(0xFF3B82F6),
  ];

  static const List<Color> cyberGradient = [
    Color(0xFF1E293B),
    Color(0xFF1E293B),
    Color(0xFF0F172A),
  ];

  static const List<Color> neonGradient = [
    Color(0xFF6366F1),
    Color(0xFF3B82F6),
    Color(0xFF10B981),
  ];
}
