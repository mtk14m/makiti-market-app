import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onAccept;

  const OrderCard({
    super.key,
    required this.order,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final timeFormatter = DateFormat('HH:mm');

    return Card(
      color: AppColors.surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.clientName,
                      style: AppTextStyles.h2.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.deliveryAddress,
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: order.type == OrderType.flash
                        ? Colors.orange[100]
                        : AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.type == OrderType.flash ? 'FLASH' : 'CLASSIQUE',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: order.type == OrderType.flash
                          ? Colors.orange[900]
                          : AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Items preview
            ...order.items.take(3).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _getZoneColor(item.zone),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${item.quantity}x ${item.productName}',
                          style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                )),
            if (order.items.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+ ${order.items.length - 3} autres articles',
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            const SizedBox(height: 12),
            const Divider(height: 1),

            const SizedBox(height: 12),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatter.format(order.totalAmount),
                      style: AppTextStyles.price.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Livraison: ${timeFormatter.format(order.estimatedDelivery ?? DateTime.now())}',
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                    ),
                  ],
                ),
                Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onAccept,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            order.status == OrderStatus.pending ? 'Accepter' : 'Voir détails',
                            style: AppTextStyles.cta.copyWith(
                              color: AppColors.textOnPrimary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            order.status == OrderStatus.pending
                                ? Icons.check_circle_outline
                                : Icons.arrow_forward_ios,
                            size: 18,
                            color: AppColors.textOnPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getZoneColor(MarketZone zone) {
    switch (zone) {
      case MarketZone.red:
        return Colors.red;
      case MarketZone.green:
        return Colors.green;
      case MarketZone.dry:
        return Colors.orange;
      case MarketZone.misc:
        return Colors.grey;
    }
  }
}

