import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  
  // Primary Colors - Neon Cyberpunk
  static const Color primary = Color(0xFF9D4EDD);
  static const Color primaryLight = Color(0xFFBE7CFF);
  static const Color primaryDark = Color(0xFF7B2CBF);
  
  // Secondary Colors - Cyan
  static const Color secondary = Color(0xFF00F5FF);
  static const Color secondaryLight = Color(0xFF8EFFFF);
  static const Color secondaryDark = Color(0xFF00C4CC);
  
  // Accent - Electric Blue
  static const Color accent = Color(0xFF00D4FF);
  static const Color accentLight = Color(0xFF7AEEFF);
  static const Color accentDark = Color(0xFF00A8CC);
  
  // Background Colors - Dark
  static const Color background = Color(0xFF0D0D1A);
  static const Color backgroundDark = Color(0xFF08080F);
  static const Color backgroundLight = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF16213E);
  static const Color surfaceLight = Color(0xFF1F2B47);
  
  // Glassmorphism
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassPrimary = Color(0x1A9D4EDD);
  static const Color glassCyan = Color(0x1A00F5FF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFE0E0E0);
  static const Color textTertiary = Color(0xFFB0B0B0);
  static const Color textHint = Color(0xFF707070);
  
  // Glow Colors
  static const Color glowPurple = Color(0xFF9D4EDD);
  static const Color glowCyan = Color(0xFF00F5FF);
  static const Color glowBlue = Color(0xFF00D4FF);
  
  // Status Colors
  static const Color success = Color(0xFF00FF88);
  static const Color error = Color(0xFFFF4D6D);
  static const Color warning = Color(0xFFFFD700);
  static const Color info = Color(0xFF4DA6FF);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF9D4EDD),
    Color(0xFF00F5FF),
  ];
  
  static const List<Color> cyberGradient = [
    Color(0xFF1A1A2E),
    Color(0xFF16213E),
    Color(0xFF0D0D1A),
  ];
  
  static const List<Color> neonGradient = [
    Color(0xFF9D4EDD),
    Color(0xFF00D4FF),
    Color(0xFF00F5FF),
  ];
}
