part of 'products_bloc.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductsEvent {
  final String? category;
  final String? search;

  const LoadProducts({this.category, this.search});

  @override
  List<Object?> get props => [category, search];
}

class FilterProducts extends ProductsEvent {
  final String? category;

  const FilterProducts({this.category});

  @override
  List<Object?> get props => [category];
}

class SearchProducts extends ProductsEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}


