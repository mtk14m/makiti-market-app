import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/entities/cart_item.dart';
import 'package:intl/intl.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChanged;

  const CartItemWidget({
    super.key,
    required this.cartItem,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  String _formatPrice(double price) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '${formatter.format(price)} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.categoryBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.image,
            color: AppColors.lightGrey,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      cartItem.product.name,
                      style: AppTextStyles.productName.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatPrice(cartItem.product.price),
                    style: AppTextStyles.price.copyWith(
                      fontSize: 14,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                cartItem.product.unit ?? 'pièce',
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
              ),
              SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'Ajouter instructions',
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Contrôles quantité
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.categoryBg,
                      borderRadius: BorderRadius.circular(20),
                      border: cartItem.quantity > 1
                          ? Border.all(color: AppColors.primary, width: 2)
                          : Border.all(color: AppColors.greyBorder, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (cartItem.quantity > 1) {
                              onQuantityChanged(cartItem.quantity - 1);
                            } else {
                              onRemove();
                            }
                          },
                          child: Icon(
                            Icons.remove,
                            size: 16,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '${cartItem.quantity}',
                            style: AppTextStyles.body.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            onQuantityChanged(cartItem.quantity + 1);
                          },
                          child: Icon(
                            Icons.add,
                            size: 16,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

