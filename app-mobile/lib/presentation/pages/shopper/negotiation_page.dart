import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../bloc/shopper/orders/orders_bloc.dart';
import '../../../domain/entities/order.dart';
import '../../widgets/animated_button.dart';
import 'widgets/price_gauge.dart';
import 'widgets/negotiation_item_card.dart';

class NegotiationPage extends StatelessWidget {
  final Order order;

  const NegotiationPage({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Négociation',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.primaryDark,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header info
            Container(
              padding: const EdgeInsets.all(20),
              color: AppColors.surfaceLight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Client: ${order.clientName}',
                    style: AppTextStyles.h2.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.deliveryAddress,
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Délai: ${order.estimatedTimeMinutes} min',
                        style: AppTextStyles.bodySecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Liste des articles par zone
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Zone Rouge
                  if (order.itemsByZone.containsKey(MarketZone.red))
                    _buildZoneSection(
                      context,
                      'Zone Rouge - Boucherie/Poissonnerie',
                      MarketZone.red,
                      order.itemsByZone[MarketZone.red]!,
                      Colors.red[100]!,
                    ),

                  // Zone Verte
                  if (order.itemsByZone.containsKey(MarketZone.green))
                    _buildZoneSection(
                      context,
                      'Zone Verte - Maraîchers',
                      MarketZone.green,
                      order.itemsByZone[MarketZone.green]!,
                      Colors.green[100]!,
                    ),

                  // Zone Sèche
                  if (order.itemsByZone.containsKey(MarketZone.dry))
                    _buildZoneSection(
                      context,
                      'Zone Sèche - Céréales/Épicerie',
                      MarketZone.dry,
                      order.itemsByZone[MarketZone.dry]!,
                      Colors.orange[100]!,
                    ),

                  // Zone Divers
                  if (order.itemsByZone.containsKey(MarketZone.misc))
                    _buildZoneSection(
                      context,
                      'Zone Divers',
                      MarketZone.misc,
                      order.itemsByZone[MarketZone.misc]!,
                      Colors.grey[300]!,
                    ),
                ],
              ),
            ),

            // Footer avec total et actions
            Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total négocié:',
                        style: AppTextStyles.body,
                      ),
                      Text(
                        NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                            .format(_calculateTotal()),
                        style: AppTextStyles.price,
                      ),
                    ],
                  ),
                  AppSpacing.gapMD,
                  AnimatedButton(
                    label: 'Valider la commande',
                    onPressed: () {
                      context.read<OrdersBloc>().add(CompleteOrder(order.id));
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text('Commande complétée avec succès!'),
                              ),
                            ],
                          ),
                          backgroundColor: AppColors.primaryDark,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    icon: Icons.check_circle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneSection(
    BuildContext context,
    String title,
    MarketZone zone,
    List<OrderItem> items,
    Color zoneColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: zoneColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NegotiationItemCard(item: item),
            )),
        const SizedBox(height: 24),
      ],
    );
  }

  double _calculateTotal() {
    double total = 0;
    for (var items in order.itemsByZone.values) {
      for (var item in items) {
        total += (item.negotiatedPrice ?? item.targetPrice) * item.quantity;
      }
    }
    return total;
  }
}

