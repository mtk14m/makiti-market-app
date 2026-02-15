import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationInitial()) {
    on<NavigateToHome>(_onNavigateToHome);
    on<NavigateToShop>(_onNavigateToShop);
    on<NavigateToCart>(_onNavigateToCart);
    on<NavigateToAccount>(_onNavigateToAccount);
  }

  void _onNavigateToHome(NavigateToHome event, Emitter<NavigationState> emit) {
    emit(NavigationHome());
  }

  void _onNavigateToShop(NavigateToShop event, Emitter<NavigationState> emit) {
    emit(NavigationShop());
  }

  void _onNavigateToCart(NavigateToCart event, Emitter<NavigationState> emit) {
    emit(NavigationCart());
  }

  void _onNavigateToAccount(
    NavigateToAccount event,
    Emitter<NavigationState> emit,
  ) {
    emit(NavigationAccount());
  }
}


