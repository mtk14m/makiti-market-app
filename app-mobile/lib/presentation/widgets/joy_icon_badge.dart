import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class JoyIconBadge extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color? iconColor;
  final Color? borderColor;
  final List<Color>? gradientColors;
  final bool circular;
  final bool elevated;
  final double size;
  final double iconSize;

  const JoyIconBadge({
    super.key,
    required this.icon,
    required this.backgroundColor,
    this.iconColor,
    this.borderColor,
    this.gradientColors,
    this.circular = false,
    this.elevated = false,
    this.size = 48,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: gradientColors == null ? backgroundColor : null,
        gradient: gradientColors == null
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors!,
              ),
        borderRadius: circular ? null : BorderRadius.circular(size * 0.34),
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        border: Border.all(
          color: borderColor ?? AppColors.cardBorder,
        ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: (iconColor ?? AppColors.textPrimary).withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor ?? AppColors.textPrimary,
        ),
      ),
    );
  }
}
