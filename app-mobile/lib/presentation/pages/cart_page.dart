import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../bloc/cart/cart_bloc.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/empty_state.dart';
import '../widgets/animated_button.dart';
import '../../core/theme/app_animations.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                if (state is CartEmpty || state.items.isEmpty) {
                  return Expanded(child: _buildEmptyCart(context));
                }

                if (state is CartLoaded) {
                  return Expanded(
                    child: Column(
                      children: [
                        _buildCartHeader(context, state),
                        Expanded(
                          child: _buildCartContent(context, state),
                        ),
                      ],
                    ),
                  );
                }

                // Fallback pour CartInitial (ne devrait pas arriver avec le nouveau code)
                return Expanded(child: _buildEmptyCart(context));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartHeader(BuildContext context, CartLoaded state) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panier',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySecondary.copyWith(fontSize: 14),
                    children: [
                      const TextSpan(text: 'Total estimé : '),
                      TextSpan(
                        text: '${formatter.format(state.totalPrice)} FCFA',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${state.totalItems} ${state.totalItems > 1 ? 'articles' : 'article'}',
            style: AppTextStyles.bodySecondary.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return EmptyState(
      icon: Icons.shopping_cart_outlined,
      title: 'Votre panier est vide',
      subtitle: 'Remplissez votre panier avec des produits frais',
      actionLabel: 'Voir les produits tendance',
      onAction: () {
        // TODO: Naviguer vers la page Shop
      },
    );
  }

  Widget _buildCartContent(BuildContext context, CartLoaded state) {
    final formatter = NumberFormat('#,##0', 'fr_FR');

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              // Liste des articles
              ...state.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: CartItemWidget(
                      cartItem: item,
                      onRemove: () {
                        context.read<CartBloc>().add(
                              RemoveFromCart(cartItemId: item.id),
                            );
                      },
                      onQuantityChanged: (quantity) {
                        context.read<CartBloc>().add(
                              UpdateQuantity(
                                cartItemId: item.id,
                                quantity: quantity,
                              ),
                            );
                      },
                    ),
                  )),
              
              // Section Points
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.card_giftcard,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                const TextSpan(text: 'Vous pourriez gagner '),
                                TextSpan(
                                  text: '${(state.totalPrice * 0.1).toInt()} points',
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const TextSpan(text: ' sur cette commande'),
                              ],
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs / 2),
                          Text(
                            'Connectez-vous ou créez un compte pour gagner des points !',
                            style: AppTextStyles.bodySecondary.copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              AppSpacing.gapMD,
              
              // Section Economies
              Container(
                padding: AppSpacing.paddingMD,
                decoration: BoxDecoration(
                  color: AppColors.categoryBg,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: AppColors.greyBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.confirmation_number,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Économies possibles !',
                            style: AppTextStyles.body.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          RichText(
                            text: TextSpan(
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                const TextSpan(text: 'Vous avez actuellement '),
                                TextSpan(
                                  text: '4 offres',
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const TextSpan(text: ' applicables aux articles de votre panier.'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.mediumGrey,
                    ),
                  ],
                ),
              ),
              
              AppSpacing.gapMD,
              
              // Détail des frais et total
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.greyBorder,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Sous-total
                    _buildFeeRow(
                      'Sous-total',
                      formatter.format(state.subtotal),
                      isBold: false,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    // Frais de service
                    _buildFeeRow(
                      'Frais de service (10%)',
                      formatter.format(state.serviceFee),
                      isBold: false,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    // Frais de transport
                    _buildFeeRow(
                      'Frais de transport',
                      formatter.format(state.deliveryFee),
                      isBold: false,
                    ),
                    SizedBox(height: AppSpacing.md),
                    // Séparateur
                    Divider(
                      height: 1,
                      color: AppColors.greyBorder,
                      thickness: 1,
                    ),
                    SizedBox(height: AppSpacing.md),
                    // Total final
                    _buildFeeRow(
                      'Total',
                      formatter.format(state.totalPrice),
                      isBold: true,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              
              AppSpacing.gapMD,
            ],
          ),
        ),
        
        // Bouton Checkout
        Container(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.md,
            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight.withOpacity(0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: AnimatedButton(
            label: 'Passer la commande',
            onPressed: () {
              context.showAnimatedSnackBar(
                'Fonctionnalité de commande bientôt disponible',
                backgroundColor: AppColors.primaryDark,
              );
            },
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            icon: Icons.shopping_cart,
          ),
        ),
      ],
    );
  }

  Widget _buildFeeRow(String label, String amount, {bool isBold = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.body.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                )
              : AppTextStyles.body.copyWith(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                  color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
                ),
        ),
        Text(
          '$amount FCFA',
          style: isTotal
              ? AppTextStyles.price.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                )
              : AppTextStyles.body.copyWith(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                  color: isTotal ? AppColors.primaryDark : AppColors.textPrimary,
                ),
        ),
      ],
    );
  }
}

