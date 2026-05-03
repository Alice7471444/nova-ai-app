import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NeonText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final double glowIntensity;

  const NeonText({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.fontWeight = FontWeight.bold,
    this.color = AppColors.primary,
    this.glowIntensity = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        shadows: [
          Shadow(
            color: color.withOpacity(0.8),
            blurRadius: 10 * glowIntensity,
          ),
          Shadow(
            color: color.withOpacity(0.5),
            blurRadius: 20 * glowIntensity,
          ),
          Shadow(
            color: color.withOpacity(0.3),
            blurRadius: 40 * glowIntensity,
          ),
        ],
      ),
    );
  }
}
