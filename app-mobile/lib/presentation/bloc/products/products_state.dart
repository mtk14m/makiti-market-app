part of 'products_bloc.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<Product> products;
  final int page;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? activeCategory;
  final String? activeSearch;

  const ProductsLoaded({
    required this.products,
    required this.page,
    required this.hasReachedMax,
    this.isLoadingMore = false,
    this.activeCategory,
    this.activeSearch,
  });

  ProductsLoaded copyWith({
    List<Product>? products,
    int? page,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? activeCategory,
    String? activeSearch,
    bool keepCategory = true,
    bool keepSearch = true,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      activeCategory: keepCategory ? activeCategory ?? this.activeCategory : activeCategory,
      activeSearch: keepSearch ? activeSearch ?? this.activeSearch : activeSearch,
    );
  }

  @override
  List<Object?> get props => [
        products,
        page,
        hasReachedMax,
        isLoadingMore,
        activeCategory,
        activeSearch,
      ];
}

class ProductsError extends ProductsState {
  final String message;

  const ProductsError(this.message);

  @override
  List<Object?> get props => [message];
}

