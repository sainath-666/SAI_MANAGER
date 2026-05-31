import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/color_palette.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final double blur;
  final BoxBorder? border;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.borderColor,
    this.backgroundColor,
    this.blur = 15.0,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBg = isDark
        ? AppColors.darkCard.withOpacity(0.45)
        : AppColors.lightCard.withOpacity(0.6);

    final defaultBorderColor = isDark
        ? AppColors.darkBorder.withOpacity(0.4)
        : AppColors.lightBorder.withOpacity(0.4);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor ?? defaultBg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ?? Border.all(
              color: borderColor ?? defaultBorderColor,
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
