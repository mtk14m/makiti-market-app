part of 'navigation_bloc.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

class NavigateToHome extends NavigationEvent {}

class NavigateToShop extends NavigationEvent {}

class NavigateToCart extends NavigationEvent {}

class NavigateToAccount extends NavigationEvent {}


