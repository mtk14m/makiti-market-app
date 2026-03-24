import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationInitial()) {
    on<NavigateToHome>(_onNavigateToHome);
    on<NavigateToExplore>(_onNavigateToExplore);
    on<NavigateToSell>(_onNavigateToSell);
    on<NavigateToMessages>(_onNavigateToMessages);
    on<NavigateToAccount>(_onNavigateToAccount);
  }

  void _onNavigateToHome(NavigateToHome event, Emitter<NavigationState> emit) {
    emit(NavigationHome());
  }

  void _onNavigateToExplore(
    NavigateToExplore event,
    Emitter<NavigationState> emit,
  ) {
    emit(NavigationExplore());
  }

  void _onNavigateToSell(
    NavigateToSell event,
    Emitter<NavigationState> emit,
  ) {
    emit(NavigationSell());
  }

  void _onNavigateToMessages(
    NavigateToMessages event,
    Emitter<NavigationState> emit,
  ) {
    emit(NavigationMessages());
  }

  void _onNavigateToAccount(
    NavigateToAccount event,
    Emitter<NavigationState> emit,
  ) {
    emit(NavigationAccount());
  }
}
