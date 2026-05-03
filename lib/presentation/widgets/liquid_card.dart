import 'package:flutter/material.dart';
import 'dart:ui';

class LiquidCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double blur;
  final double borderRadius;

  const LiquidCard({
    super.key,
    required this.child,
    this.padding,
    this.blur = 10,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}
