part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddToCart extends CartEvent {
  final Product product;

  const AddToCart(this.product);

  @override
  List<Object?> get props => [product];
}

class RemoveFromCart extends CartEvent {
  final String cartItemId;

  const RemoveFromCart({required this.cartItemId});

  @override
  List<Object?> get props => [cartItemId];
}

class UpdateQuantity extends CartEvent {
  final String cartItemId;
  final int quantity;

  const UpdateQuantity({
    required this.cartItemId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [cartItemId, quantity];
}

class ClearCart extends CartEvent {
  const ClearCart();
}

class LoadCart extends CartEvent {
  final List<CartItem> items;

  const LoadCart(this.items);

  @override
  List<Object?> get props => [items];
}


