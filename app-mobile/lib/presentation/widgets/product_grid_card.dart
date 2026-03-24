import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/image_url_helper.dart';
import '../../domain/entities/product.dart';

class ProductGridCard extends StatelessWidget {
  final Product product;
  final VoidCallback onPrimaryAction;

  const ProductGridCard({
    super.key,
    required this.product,
    required this.onPrimaryAction,
  });

  String _formatPrice(double price) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '${formatter.format(price)} FCFA';
  }

  String _subtitle() {
    if ((product.unit ?? '').isNotEmpty) return product.unit!;
    if (product.category.isNotEmpty) return product.category;
    return 'Taille unique';
  }

  IconData _fallbackIcon() {
    final value = product.category.toLowerCase();
    if (value.contains('chauss')) return PhosphorIcons.sneaker();
    if (value.contains('maison')) return PhosphorIcons.house();
    if (value.contains('tech')) return PhosphorIcons.deviceMobile();
    if (value.contains('beaute')) return PhosphorIcons.sparkle();
    return PhosphorIcons.tShirt();
  }

  @override
  Widget build(BuildContext context) {
    final reviewLabel = product.reviewCount > 0 ? product.reviewCount : 24;

    return InkWell(
      onTap: onPrimaryAction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.82,
            child: Stack(
              children: [
                Positioned.fill(
                  child: product.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: ImageUrlHelper.addCacheBuster(
                            product.imageUrl,
                            product.id,
                          ),
                          fit: BoxFit.cover,
                          cacheKey: 'product_${product.id}',
                          placeholder: (context, url) => Container(
                            color: AppColors.categoryBg,
                          ),
                          errorWidget: (context, url, error) => _ImageFallback(
                            icon: _fallbackIcon(),
                          ),
                        )
                      : _ImageFallback(icon: _fallbackIcon()),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    color: AppColors.surfaceLight,
                    child: Text(
                      product.isAvailable ? 'Disponible' : 'Réservé',
                      style: AppTextStyles.bodySecondary.copyWith(
                        fontSize: 11,
                        color: product.isAvailable
                            ? AppColors.primaryDark
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    color: AppColors.surfaceLight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIcons.heart(),
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$reviewLabel',
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.productName.copyWith(
              fontSize: 17,
              height: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _subtitle(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 10),
          if (product.hasDiscount && product.originalPrice != null) ...[
            Text(
              _formatPrice(product.originalPrice!),
              style: AppTextStyles.priceStrikethrough.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 2),
          ],
          Text(
            _formatPrice(product.price),
            style: AppTextStyles.price.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                PhosphorIcons.shieldCheck(),
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${_formatPrice(product.price * 1.08)} incl.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final IconData icon;

  const _ImageFallback({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.categoryBg,
      child: Center(
        child: Icon(
          icon,
          size: 34,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
