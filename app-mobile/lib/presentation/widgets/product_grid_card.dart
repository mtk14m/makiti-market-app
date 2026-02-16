import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/image_url_helper.dart';
import '../../domain/entities/product.dart';
import 'package:intl/intl.dart';

class ProductGridCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductGridCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      color: AppColors.surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Colors.grey[100]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Image du produit
                      product.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              // Ajoute un paramètre de version pour forcer le rechargement si l'image change
                              imageUrl: ImageUrlHelper.addCacheBuster(product.imageUrl, product.id),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              // Cache key unique basé sur l'ID du produit
                              cacheKey: 'product_${product.id}',
                              // Max cache duration réduit pour permettre les mises à jour
                              maxHeightDiskCache: 400,
                              maxWidthDiskCache: 400,
                              placeholder: (context, url) => Container(
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
                                color: AppColors.categoryBg,
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                    color: AppColors.lightGrey,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.categoryBg,
                              child: Center(
                                child: Icon(
                                  Icons.image,
                                  size: 60,
                                  color: AppColors.lightGrey,
                                ),
                              ),
                            ),
                    // Bouton Add en bas à droite - doit être au-dessus (z-index plus élevé)
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: Material(
                        color: Colors.transparent,
                        elevation: 4,
                        child: InkWell(
                          onTap: onAddToCart,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add,
                              color: AppColors.textOnPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md - AppSpacing.xs),
            // Prix
            Text(
              formatter.format(product.price),
              style: AppTextStyles.price.copyWith(fontSize: 18),
            ),
            SizedBox(height: AppSpacing.xs),
            // Nom produit
            Text(
              product.name,
              style: AppTextStyles.productName.copyWith(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSpacing.xs),
            // Description/Unit
            Text(
              product.unit ?? product.description,
              style: AppTextStyles.productDescription.copyWith(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSpacing.xs),
            // Rating
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 12,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  '${product.rating}',
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  '(${product.reviewCount})',
                  style: AppTextStyles.bodySecondary.copyWith(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


