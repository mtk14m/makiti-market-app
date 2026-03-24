part of 'navigation_bloc.dart';

abstract class NavigationState extends Equatable {
  const NavigationState();

  @override
  List<Object?> get props => [];
}

class NavigationInitial extends NavigationState {}

class NavigationHome extends NavigationState {}

class NavigationExplore extends NavigationState {}

class NavigationSell extends NavigationState {}

class NavigationMessages extends NavigationState {}

class NavigationAccount extends NavigationState {}
