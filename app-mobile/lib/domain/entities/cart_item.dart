import 'package:equatable/equatable.dart';
import 'product.dart';

/// Article dans le panier
class CartItem extends Equatable {
  final String id;
  final Product product;
  final double quantity; // Quantité en kg, litre, ou pièce selon l'unité du produit

  const CartItem({
    required this.id,
    required this.product,
    this.quantity = 1.0,
  });

  /// Calcule le prix total selon la quantité et l'unité
  /// Le prix du produit est toujours au kg/litre/pièce selon l'unité
  double get totalPrice {
    return product.price * quantity;
  }

  /// Retourne la quantité formatée avec l'unité
  String get formattedQuantity {
    final unit = product.unit ?? 'pièce';
    if (quantity == quantity.toInt()) {
      return '${quantity.toInt()} $unit';
    }
    return '${quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 2)} $unit';
  }

  CartItem copyWith({
    String? id,
    Product? product,
    double? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [id, product, quantity];
}


