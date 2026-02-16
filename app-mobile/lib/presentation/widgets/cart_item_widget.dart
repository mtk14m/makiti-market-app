import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/image_url_helper.dart';
import '../../domain/entities/cart_item.dart';
import 'package:intl/intl.dart';

class CartItemWidget extends StatefulWidget {
  final CartItem cartItem;
  final VoidCallback onRemove;
  final ValueChanged<double> onQuantityChanged;

  const CartItemWidget({
    super.key,
    required this.cartItem,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  late final TextEditingController _quantityController;
  final FocusNode _quantityFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialiser le contrôleur avec la valeur actuelle
    _quantityController = TextEditingController(
      text: widget.cartItem.quantity.toStringAsFixed(
        widget.cartItem.quantity.truncateToDouble() == widget.cartItem.quantity ? 0 : 2,
      ),
    );
    _quantityFocusNode.addListener(() {
      if (!_quantityFocusNode.hasFocus) {
        _updateQuantityFromText();
      }
    });
  }

  @override
  void didUpdateWidget(CartItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cartItem.quantity != widget.cartItem.quantity) {
      _updateControllerText();
    }
  }

  void _updateControllerText() {
    _quantityController.text = widget.cartItem.quantity.toStringAsFixed(
      widget.cartItem.quantity.truncateToDouble() == widget.cartItem.quantity ? 0 : 2,
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }

  void _updateQuantityFromText() {
    final text = _quantityController.text.replaceAll(',', '.');
    final quantity = double.tryParse(text);
    if (quantity != null && quantity > 0) {
      widget.onQuantityChanged(quantity);
    } else {
      // Restaurer la valeur précédente si invalide
      _quantityController.text = widget.cartItem.quantity.toStringAsFixed(
        widget.cartItem.quantity.truncateToDouble() == widget.cartItem.quantity ? 0 : 2,
      );
    }
  }

  void _incrementQuantity() {
    final currentQuantity = widget.cartItem.quantity;
    final unit = widget.cartItem.product.unit?.toLowerCase() ?? 'pièce';
    // Pour kg et L, incrément de 0.5, pour pièce incrément de 1
    final increment = (unit == 'kg' || unit == 'l' || unit == 'litre') ? 0.5 : 1.0;
    final newQuantity = currentQuantity + increment;
    widget.onQuantityChanged(newQuantity);
    _quantityController.text = newQuantity.toStringAsFixed(
      newQuantity.truncateToDouble() == newQuantity ? 0 : 2,
    );
  }

  void _decrementQuantity() {
    final currentQuantity = widget.cartItem.quantity;
    final unit = widget.cartItem.product.unit?.toLowerCase() ?? 'pièce';
    // Pour kg et L, décrément de 0.5, pour pièce décrément de 1
    final decrement = (unit == 'kg' || unit == 'l' || unit == 'litre') ? 0.5 : 1.0;
    if (currentQuantity > decrement) {
      final newQuantity = currentQuantity - decrement;
      widget.onQuantityChanged(newQuantity);
      _quantityController.text = newQuantity.toStringAsFixed(
        newQuantity.truncateToDouble() == newQuantity ? 0 : 2,
      );
    } else {
      widget.onRemove();
    }
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '${formatter.format(price)} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    final cartItem = widget.cartItem;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: cartItem.product.imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  // Ajoute un paramètre de version pour forcer le rechargement si l'image change
                  imageUrl: ImageUrlHelper.addCacheBuster(cartItem.product.imageUrl, cartItem.product.id),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  // Cache key unique basé sur l'ID du produit
                  cacheKey: 'product_${cartItem.product.id}',
                  // Max cache duration réduit pour permettre les mises à jour
                  maxHeightDiskCache: 200,
                  maxWidthDiskCache: 200,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.categoryBg,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
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
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.categoryBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.image_not_supported,
                      color: AppColors.lightGrey,
                      size: 32,
                    ),
                  ),
                )
              : Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.categoryBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.image,
                    color: AppColors.lightGrey,
                    size: 32,
                  ),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cartItem.product.name,
                          style: AppTextStyles.productName.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppSpacing.xs / 2),
                        Text(
                          '${_formatPrice(cartItem.product.price)} / ${cartItem.product.unit ?? 'pièce'}',
                          style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatPrice(cartItem.totalPrice),
                        style: AppTextStyles.price.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs / 2),
                      Text(
                        cartItem.formattedQuantity,
                        style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: TextButton(
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
                          Flexible(
                            child: Text(
                              'Ajouter instructions',
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 12,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  // Contrôles quantité avec saisie
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.categoryBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _quantityFocusNode.hasFocus 
                            ? AppColors.primary 
                            : AppColors.greyBorder,
                        width: _quantityFocusNode.hasFocus ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _decrementQuantity,
                          child: Icon(
                            Icons.remove,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: TextField(
                            controller: _quantityController,
                            focusNode: _quantityFocusNode,
                            textAlign: TextAlign.center,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: AppTextStyles.body.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                              isDense: true,
                            ),
                            onSubmitted: (_) => _updateQuantityFromText(),
                          ),
                        ),
                        GestureDetector(
                          onTap: _incrementQuantity,
                          child: Icon(
                            Icons.add,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          cartItem.product.unit ?? 'pièce',
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
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

