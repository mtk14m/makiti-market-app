import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class PromotionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int? discount;

  const PromotionCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.discount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 292,
      height: 132,
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: discount != null
              ? [
                  AppColors.secondary.withValues(alpha: 0.95),
                  AppColors.secondary.withValues(alpha: 0.72),
                ]
              : [
                  AppColors.primaryDark,
                  AppColors.darkGrey,
                ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (discount != null)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$discount%',
                  style: AppTextStyles.bodySecondary.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (discount != null) SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: AppTextStyles.h2.copyWith(
                  color: discount != null ? AppColors.textOnPrimary : AppColors.textOnDark,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTextStyles.bodySecondary.copyWith(
                  color: discount != null 
                      ? AppColors.textPrimary.withOpacity(0.82)
                      : AppColors.textOnDark.withOpacity(0.9),
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    'Découvrir',
                    style: AppTextStyles.body.copyWith(
                      color: discount != null
                          ? AppColors.textPrimary
                          : AppColors.textOnDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: discount != null
                        ? AppColors.textPrimary
                        : AppColors.textOnDark,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
