import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/order.dart';
import 'price_gauge.dart';

class NegotiationItemCard extends StatefulWidget {
  final OrderItem item;

  const NegotiationItemCard({
    super.key,
    required this.item,
  });

  @override
  State<NegotiationItemCard> createState() => _NegotiationItemCardState();
}

class _NegotiationItemCardState extends State<NegotiationItemCard> {
  late double negotiatedPrice;
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    negotiatedPrice = widget.item.negotiatedPrice ?? widget.item.targetPrice;
    _priceController.text = negotiatedPrice.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  bool _isPriceValid() {
    final floorPrice = widget.item.targetPrice * 0.8;
    final ceilingPrice = widget.item.targetPrice * 1.1;
    return negotiatedPrice >= floorPrice && negotiatedPrice <= ceilingPrice;
  }

  String? _getPriceHelperText() {
    final floorPrice = widget.item.targetPrice * 0.8;
    final ceilingPrice = widget.item.targetPrice * 1.1;
    
    if (negotiatedPrice < floorPrice) {
      return 'Prix trop bas (min: \$${floorPrice.toStringAsFixed(2)})';
    } else if (negotiatedPrice > ceilingPrice) {
      return 'Prix trop élevé (max: \$${ceilingPrice.toStringAsFixed(2)})';
    }
    return null;
  }

  Widget? _getPriceValidationIcon() {
    if (!_isPriceValid()) {
      return const Icon(Icons.warning_amber_rounded, color: Colors.orange);
    }
    return const Icon(Icons.check_circle, color: Colors.green);
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final floorPrice = widget.item.targetPrice * 0.8; // -20%
    final ceilingPrice = widget.item.targetPrice * 1.1; // +10%

    return Card(
      color: AppColors.surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom du produit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.item.productName,
                    style: AppTextStyles.productName.copyWith(fontSize: 16),
                  ),
                ),
                Text(
                  '${widget.item.quantity}x ${widget.item.unit ?? "unité"}',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Intervalle de prix simplifié
            PriceGauge(
              minPrice: floorPrice,
              maxPrice: ceilingPrice,
              currentPrice: negotiatedPrice,
            ),

            const SizedBox(height: 16),

            // Input prix avec validation visuelle
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Prix négocié',
                      prefixText: '\$ ',
                      helperText: _getPriceHelperText(),
                      helperMaxLines: 2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundLight,
                      suffixIcon: _getPriceValidationIcon(),
                    ),
                    onChanged: (value) {
                      final price = double.tryParse(value);
                      if (price != null) {
                        setState(() {
                          negotiatedPrice = price;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Bouton Validé avec feedback visuel
                Material(
                  color: _isPriceValid() ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: _isPriceValid()
                        ? () {
                            // TODO: Sauvegarder le prix négocié
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${widget.item.productName} validé à ${formatter.format(negotiatedPrice)}',
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: const Icon(Icons.check, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Économies
            if (negotiatedPrice < widget.item.targetPrice)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.savings, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Économie: ${formatter.format((widget.item.targetPrice - negotiatedPrice) * widget.item.quantity)}',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

