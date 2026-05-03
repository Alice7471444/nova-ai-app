import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════
  // iOS 26 LIQUID GLASS - Futuristic Premium Design
  // ═════════════════════════════════════════════════════════════

  // Primary - Futuristic Purple/Blue
  static const Color primary = Color(0xFF667EEA);
  static const Color primaryLight = Color(0xFF9F7AEA);
  static const Color primaryDark = Color(0xFF4C6ED6);

  // Secondary - Accent Cyan
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color secondaryLight = Color(0xFF6EE7DE);
  static const Color secondaryDark = Color(0xFF36B9B0);

  // Accent - Magical Pink
  static const Color accent = Color(0xFFF093FB);
  static const Color accentLight = Color(0xFFF5A8F9);
  static const accentDark = Color(0xFFD558F5);

  // ═══════════════════════════════════════════════════════════════
  // Background - Deep Dark (Liquid Glass)
  // ═════════════════════════════════════════════════════════════
  static const Color background = Color(0xFF0A0A0F);
  static const backgroundDark = Color(0xFF000000);
  static const backgroundLight = Color(0xFF1C1C2E);
  static const backgroundCard = Color(0xFF16161F);
  static const surface = Color(0xFF1A1A28);
  static const surfaceLight = Color(0xFF242438);

  // ═══════════════════════════════════════════════════════════════
  // Liquid Glass Effects
  // ═════════════════════════════════════════════════════════════
  static const Color glassWhite = Color(0x12FFFFFF);
  static const glassPrimary = Color(0x1A667EEA);
  static const glassCyan = Color(0x1A4ECDC4);
  static const glassPink = Color(0x1AF093FB);
  static const glassBorder = Color(0x2EFFFFFF);
  static const glassBorderLight = Color(0x08FFFFFF);

  // Gradient Effects
  static const List<Color> primaryGradient = [
    Color(0xFF667EEA),
    Color(0xFFF093FB),
  ];

  static const List<Color> glassGradient = [
    Color(0xFF667EEA),
    Color(0xFF4ECDC4),
  ];

  static const List<Color> darkGradient = [
    Color(0xFF1C1C2E),
    Color(0xFF16161F),
  ];

  static const List<Color> neonGradient = [
    Color(0xFF667EEA),
    Color(0xFF4ECDC4),
    Color(0xFFF093FB),
  ];

  // ═══════════════════════════════════════════════════════════════
  // Text - Premium White
  // ═════════════════════════════════════════════════════════════
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFE0E0E8);
  static const textTertiary = Color(0xFF8E8E9A);
  static const textHint = Color(0xFF5A5A6A);

  // Dark mode text (already dark in this theme)
  static const textPrimaryDark = Color(0xFFFFFFFF);
  static const textSecondaryDark = Color(0xFFE0E0E8);
  static const textTertiaryDark = Color(0xFF8E8E9A);

  // ═══════════════════════════════════════════════════════════════
  // Status Colors
  // ═════════════════════════════════════════════════════════════
  static const success = Color(0xFF4ECDC4);
  static const error = Color(0xFFFF6B6B);
  static const warning = Color(0xFFFFD93D);
  static const info = Color(0xFF667EEA);

  // ═══════════════════════════════════════════════════════════════
  // Shadows - iOS 26 Liquid Glow
  // ═════════════════════════════════════════════════════════════
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Color(0x40667EEA),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Color(0x20667EEA),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: Color(0x60667EEA),
      blurRadius: 30,
      spreadRadius: 5,
    ),
  ];
}
