part of 'navigation_bloc.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

class NavigateToHome extends NavigationEvent {}

class NavigateToExplore extends NavigationEvent {}

class NavigateToSell extends NavigationEvent {}

class NavigateToMessages extends NavigationEvent {}

class NavigateToAccount extends NavigationEvent {}
