import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/image_url_helper.dart';
import '../../domain/entities/product.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  String _formatPrice(double price) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '${formatter.format(price)} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: AppColors.surfaceLight,
                    pinned: true,
                    elevation: 0,
                    leading: _IconButtonTile(
                      icon: PhosphorIcons.caretLeft(),
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    actions: [
                      _IconButtonTile(
                        icon: PhosphorIcons.heart(),
                        onTap: () {},
                      ),
                      const SizedBox(width: 8),
                      _IconButtonTile(
                        icon: PhosphorIcons.shareNetwork(),
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                    ],
                    expandedHeight: 420,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        color: AppColors.inputBackground,
                        child: product.imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: ImageUrlHelper.addCacheBuster(
                                  product.imageUrl,
                                  product.id,
                                ),
                                fit: BoxFit.contain,
                              )
                            : Center(
                                child: Icon(
                                  PhosphorIcons.image(),
                                  size: 88,
                                  color: AppColors.lightGrey,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: AppTextStyles.h1.copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatPrice(product.price),
                                style: AppTextStyles.price.copyWith(fontSize: 28),
                              ),
                              if (product.hasDiscount && product.originalPrice != null) ...[
                                const SizedBox(width: 10),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    _formatPrice(product.originalPrice!),
                                    style: AppTextStyles.priceStrikethrough.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            [
                              if (product.category.isNotEmpty) product.category,
                              if ((product.unit ?? '').isNotEmpty) product.unit!,
                            ].join(' · ').isNotEmpty
                                ? [
                                    if (product.category.isNotEmpty) product.category,
                                    if ((product.unit ?? '').isNotEmpty) product.unit!,
                                  ].join(' · ')
                                : 'Disponible',
                            style: AppTextStyles.bodySecondary,
                          ),
                          const SizedBox(height: 18),
                          _InfoCard(
                            title: 'Détails',
                            child: Column(
                              children: [
                                _InfoRow(label: 'Catégorie', value: product.category),
                                _InfoRow(
                                  label: 'État',
                                  value: product.isAvailable ? 'Disponible' : 'Indisponible',
                                ),
                                if ((product.unit ?? '').isNotEmpty)
                                  _InfoRow(label: 'Taille / format', value: product.unit!),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          _InfoCard(
                            title: 'Description',
                            child: Text(
                              product.description.isNotEmpty
                                  ? product.description
                                  : 'Article disponible sur Makiti.',
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _InfoCard(
                            title: 'Livraison et protection',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _MiniLine(
                                  icon: PhosphorIcons.package(),
                                  label: 'Retrait en box Makiti',
                                ),
                                const SizedBox(height: 10),
                                _MiniLine(
                                  icon: PhosphorIcons.shieldCheck(),
                                  label: 'Protection acheteur incluse',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          _InfoCard(
                            title: 'Vendeur',
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryLight,
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: Icon(
                                    PhosphorIcons.user(),
                                    size: 18,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Vendeur Makiti',
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Réponse rapide · profil vérifié',
                                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: const BoxDecoration(
                color: AppColors.surfaceLight,
                border: Border(top: BorderSide(color: AppColors.cardBorder)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.cardBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Faire une offre',
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Acheter'),
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
}

class _IconButtonTile extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButtonTile({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: AppColors.white.withValues(alpha: 0.94),
        shape: const RoundedRectangleBorder(),
        child: InkWell(
          customBorder: const RoundedRectangleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 18, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.bodySecondary),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniLine extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniLine({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryDark),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySecondary.copyWith(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
