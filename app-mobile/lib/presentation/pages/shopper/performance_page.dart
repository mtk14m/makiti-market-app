import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/shopper_performance.dart';

class PerformancePage extends StatelessWidget {
  final ShopperPerformance performance;

  const PerformancePage({
    super.key,
    required this.performance,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Performance',
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Badge de rang
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getRankColors(performance.rank),
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            performance.rankLabel,
                            style: AppTextStyles.h1.copyWith(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rang actuel',
                            style: AppTextStyles.bodySecondary.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Statistiques principales
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Commandes',
                            '${performance.completedOrders}',
                            Icons.shopping_bag,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Note moyenne',
                            performance.averageRating.toStringAsFixed(1),
                            Icons.star,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Score précision',
                            '${(performance.accuracyScore * 100).toInt()}%',
                            Icons.gps_fixed,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Série actuelle',
                            '${performance.currentStreak}',
                            Icons.local_fire_department,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Détails
                    Card(
                      color: AppColors.surfaceLight,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Détails',
                              style: AppTextStyles.sectionTitle,
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow('Total gagné', '\$${performance.totalEarnings.toStringAsFixed(2)}'),
                            _buildDetailRow('Bonus négociation', '\$${performance.totalBonus.toStringAsFixed(2)}'),
                            _buildDetailRow('Évaluations', '${performance.totalRatings}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      color: AppColors.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryDark, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.price.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body),
          Text(
            value,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<Color> _getRankColors(ShopperRank rank) {
    switch (rank) {
      case ShopperRank.bronze:
        return [Colors.brown[400]!, Colors.brown[600]!];
      case ShopperRank.silver:
        return [Colors.grey[400]!, Colors.grey[600]!];
      case ShopperRank.gold:
        return [Colors.amber[400]!, Colors.amber[600]!];
    }
  }
}

