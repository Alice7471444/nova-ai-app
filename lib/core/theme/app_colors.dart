import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // iOS Liquid Glass Style - Premium Minimal
  
  // Primary - Apple-style blue
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryLight = Color(0xFF5AC8FA);
  static const Color primaryDark = Color(0xFF0051DB);
  
  // Secondary - Clean gray
  static const Color secondary = Color(0xFF8E8E93);
  static const Color secondaryLight = Color(0xFFAEAEB2);
  static const Color secondaryDark = Color(0xFF636366);
  
  // Accent - iOS Green
  static const Color accent = Color(0xFF34C759);
  static const Color accentLight = Color(0xFF30D158);
  static const Color accentDark = Color(0xFF248A3D);
  
  // Background - iOS System
  static const Color background = Color(0xFFF2F2F7);  // iOS system gray
  static const Color backgroundDark = Color(0xFF000000);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundCard = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF2F2F7);
  
  // Glass (softer blur)
  static const Color glassWhite = Color(0x08FFFFFF);
  static const Color glassPrimary = Color(0x0A007AFF);
  static const Color glassCyan = Color(0x0A5AC8FA);
  
  // Text - iOS
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF3C3C43);
  static const Color textTertiary = Color(0xFF8E8E93);
  static const Color textHint = Color(0xFFC7C7CC);
  
  // Dark mode text
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFEBEBF5);
  static const Color textTertiaryDark = Color(0xFF8E8E93);
  
  // Status
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF5AC8FA);
  
  // Gradients (subtle iOS)
  static const List<Color> primaryGradient = [
    Color(0xFF007AFF),
    Color(0xFF5AC8FA),
  ];
  
  static const List<Color> glassGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF2F2F7),
  ];
  
  static const List<Color> darkGradient = [
    Color(0xFF1C1C1E),
    Color(0xFF2C2C2E),
  ];
  
  // Shadows (iOS style)
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];
}
