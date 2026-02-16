part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  /// Sous-total des produits (sans frais)
  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Frais de service (10% du sous-total pour l'instant, dynamique après)
  double get serviceFee {
    return subtotal * 0.10; // 10% pour l'instant
  }

  /// Frais de transport (dynamique selon la distance, fixe à 2000 FCFA pour l'instant)
  double get deliveryFee {
    // TODO: Calculer dynamiquement selon la distance
    // Pour l'instant, frais fixes de 2000 FCFA
    return 2000.0;
  }

  /// Total final (sous-total + frais de service + frais de transport)
  double get totalPrice {
    return subtotal + serviceFee + deliveryFee;
  }

  /// Nombre total d'articles dans le panier (arrondi à l'entier supérieur pour l'affichage)
  int get totalItems {
    return items.length; // Nombre d'articles différents
  }

  /// Nombre total d'unités dans le panier (pour le badge)
  int get totalUnits {
    return items.fold(0, (sum, item) => sum + item.quantity.ceil());
  }

  @override
  List<Object?> get props => [items];
}

class CartInitial extends CartState {
  const CartInitial() : super(items: const []);
}

class CartEmpty extends CartState {
  const CartEmpty() : super(items: const []);
}

class CartLoaded extends CartState {
  const CartLoaded({required List<CartItem> items}) : super(items: items);
}


