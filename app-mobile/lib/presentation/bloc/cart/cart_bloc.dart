import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/product.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
    on<LoadCart>(_onLoadCart);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final currentItems = state.items;
    final existingItemIndex = currentItems.indexWhere(
      (item) => item.product.id == event.product.id,
    );

    List<CartItem> updatedItems;

    if (existingItemIndex >= 0) {
      // Augmenter la quantité si le produit existe déjà
      updatedItems = List.from(currentItems);
      updatedItems[existingItemIndex] = updatedItems[existingItemIndex]
          .copyWith(quantity: updatedItems[existingItemIndex].quantity + 1);
    } else {
      // Ajouter un nouvel article
      updatedItems = [
        ...currentItems,
        CartItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          product: event.product,
          quantity: 1,
        ),
      ];
    }

    emit(CartLoaded(items: updatedItems));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final updatedItems = state.items
        .where((item) => item.id != event.cartItemId)
        .toList();

    if (updatedItems.isEmpty) {
      emit(CartEmpty());
    } else {
      emit(CartLoaded(items: updatedItems));
    }
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) {
    if (event.quantity <= 0) {
      add(RemoveFromCart(cartItemId: event.cartItemId));
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.id == event.cartItemId) {
        return item.copyWith(quantity: event.quantity);
      }
      return item;
    }).toList();

    emit(CartLoaded(items: updatedItems));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(CartEmpty());
  }

  void _onLoadCart(LoadCart event, Emitter<CartState> emit) {
    if (event.items.isEmpty) {
      emit(CartEmpty());
    } else {
      emit(CartLoaded(items: event.items));
    }
  }
}


