import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Widget de chargement avec effet shimmer (inspiré des apps modernes)
class LoadingShimmer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const LoadingShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[300]!,
              Colors.grey[100]!,
              Colors.grey[300]!,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: Container(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Liste de shimmer pour les cartes de produits
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LoadingShimmer(
              width: double.infinity,
              height: 120,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 12),
            LoadingShimmer(width: 150, height: 16),
            const SizedBox(height: 8),
            LoadingShimmer(width: 100, height: 14),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LoadingShimmer(width: 80, height: 20),
                LoadingShimmer(width: 40, height: 40, borderRadius: BorderRadius.circular(20)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


