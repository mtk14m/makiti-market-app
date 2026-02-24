import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartState.initial()) {
    on<CartItemAdded>(_onItemAdded);
  }

  void _onItemAdded(CartItemAdded event, Emitter<CartState> emit) {
    emit(state.copyWith(itemCount: state.itemCount + 1));
  }
}