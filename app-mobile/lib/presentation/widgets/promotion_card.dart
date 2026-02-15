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
      width: 280,
      height: 160,
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: discount != null ? AppColors.primary : AppColors.darkGrey,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Badge pourcentage si discount - doit être au-dessus (z-index plus élevé)
          if (discount != null)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$discount%',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          // Contenu principal
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppTextStyles.h2.copyWith(
                  color: discount != null ? AppColors.textOnPrimary : AppColors.textOnDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTextStyles.bodySecondary.copyWith(
                  color: discount != null 
                      ? AppColors.textOnPrimary.withOpacity(0.8)
                      : AppColors.textOnDark.withOpacity(0.9),
                  fontSize: 10,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Icon(
                Icons.arrow_forward,
                color: discount != null ? AppColors.textOnPrimary : AppColors.textOnDark,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

