import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Widget simplifié pour afficher l'intervalle de prix
/// Affiche simplement "Entre X et Y" pour plus de clarté
class PriceGauge extends StatelessWidget {
  final double minPrice;
  final double maxPrice;
  final double? currentPrice;

  const PriceGauge({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            'Entre ${formatter.format(minPrice)} et ${formatter.format(maxPrice)}',
            style: AppTextStyles.bodySecondary.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

