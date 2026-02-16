import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/image_url_helper.dart';
import '../../domain/entities/product.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  String _formatPrice(double price) {
    // Format pour FCFA (Franc CFA) - devise ouest-africaine
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '${formatter.format(price)} FCFA';
  }

  String _getUnitLabel() {
    // Retourne l'unité ou une unité par défaut selon le contexte
    if (product.unit != null && product.unit!.isNotEmpty) {
      return product.unit!;
    }
    // Unités courantes au marché ouest-africain
    if (product.category.toLowerCase().contains('viande') ||
        product.category.toLowerCase().contains('poisson')) {
      return 'kg';
    }
    if (product.category.toLowerCase().contains('légume') ||
        product.category.toLowerCase().contains('fruit')) {
      return 'kg';
    }
    return 'pièce';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.sm + AppSpacing.xs), // 12px
        side: BorderSide(
          color: AppColors.greyBorder,
          width: 1,
        ),
      ),
      color: AppColors.surfaceLight,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + AppSpacing.xs, // 12px
          vertical: AppSpacing.sm + 2, // 10px (proche de sm)
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image du produit
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              child: product.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      // Ajoute un paramètre de version pour forcer le rechargement si l'image change
                      imageUrl: ImageUrlHelper.addCacheBuster(product.imageUrl, product.id),
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      // Cache key unique basé sur l'ID du produit
                      cacheKey: 'product_${product.id}',
                      // Max cache duration réduit pour permettre les mises à jour
                      maxHeightDiskCache: 200,
                      maxWidthDiskCache: 200,
                      placeholder: (context, url) => Container(
                        width: 70,
                        height: 70,
                        color: AppColors.categoryBg,
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.categoryBg,
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                        ),
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColors.lightGrey,
                          size: 32,
                        ),
                      ),
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.categoryBg,
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                      child: Icon(
                        Icons.shopping_basket,
                        color: AppColors.primary.withOpacity(0.6),
                        size: 32,
                      ),
                    ),
            ),
            SizedBox(width: AppSpacing.sm),
            // Contenu principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nom du produit
                  Text(
                    product.name,
                    style: AppTextStyles.productName.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  // Prix avec unité
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _formatPrice(product.price),
                        style: AppTextStyles.price.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        '/ ${_getUnitLabel()}',
                        style: AppTextStyles.bodySecondary.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs),
                  // Badge fraîcheur et disponibilité
                  Row(
                    children: [
                      if (product.isAvailable)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs + 2, // 6px
                            vertical: AppSpacing.xs / 2, // 2px
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.xs),
                          ),
                          child: Text(
                            'Frais du jour',
                            style: AppTextStyles.bodySecondary.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      if (!product.isAvailable) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs + 2, // 6px
                            vertical: AppSpacing.xs / 2, // 2px
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textTertiary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.xs),
                          ),
                          child: Text(
                            'Indisponible',
                            style: AppTextStyles.bodySecondary.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            // Bouton Add - plus compact
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: product.isAvailable ? onAddToCart : null,
                borderRadius: BorderRadius.circular(20), // 20px pour cercle de 40px
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: product.isAvailable
                        ? AppColors.primary
                        : AppColors.greyButton,
                    shape: BoxShape.circle,
                    boxShadow: product.isAvailable
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.add,
                    color: product.isAvailable
                        ? AppColors.textOnPrimary
                        : AppColors.textTertiary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

