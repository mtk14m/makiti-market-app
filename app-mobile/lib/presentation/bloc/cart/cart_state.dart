part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  double get totalPrice {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
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


