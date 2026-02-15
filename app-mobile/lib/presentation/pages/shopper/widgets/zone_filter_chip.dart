import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/order.dart';

class ZoneFilterChip extends StatelessWidget {
  final String label;
  final MarketZone? zone;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const ZoneFilterChip({
    super.key,
    required this.label,
    required this.zone,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (color ?? AppColors.primary)
                : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? null
                : Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? (color != null ? AppColors.textPrimary : AppColors.textOnPrimary)
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}


