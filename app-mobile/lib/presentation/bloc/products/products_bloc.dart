import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';
import '../../../data/repositories/products_repository.dart';
import '../../../core/errors/api_exception.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  static const int _pageSize = 12;
  final ProductsRepository repository;

  ProductsBloc({ProductsRepository? repository})
      : repository = repository ?? ProductsRepository(),
        super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<FilterProducts>(_onFilterProducts);
    on<SearchProducts>(_onSearchProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsLoading());

    try {
      final result = await repository.getProductsPage(
        page: 1,
        pageSize: _pageSize,
        category: event.category,
        search: event.search,
        isAvailable: true,
      );
      emit(
        ProductsLoaded(
          products: result.items,
          page: result.page,
          hasReachedMax: !result.hasMore,
          activeCategory: event.category,
          activeSearch: event.search,
        ),
      );
    } catch (e) {
      emit(ProductsError(
        e is ApiException ? e.message : 'Erreur lors du chargement des produits',
      ));
    }
  }

  Future<void> _onFilterProducts(
    FilterProducts event,
    Emitter<ProductsState> emit,
  ) async {
    return _onLoadProducts(
      LoadProducts(category: event.category),
      emit,
    );
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductsState> emit,
  ) async {
    return _onLoadProducts(
      LoadProducts(search: event.query),
      emit,
    );
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProductsLoaded ||
        currentState.hasReachedMax ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final result = await repository.getProductsPage(
        page: currentState.page + 1,
        pageSize: _pageSize,
        category: currentState.activeCategory,
        search: currentState.activeSearch,
        isAvailable: true,
      );

      emit(
        currentState.copyWith(
          products: [...currentState.products, ...result.items],
          page: result.page,
          hasReachedMax: !result.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(isLoadingMore: false),
      );
      emit(ProductsError(
        e is ApiException ? e.message : 'Erreur lors du chargement supplementaire',
      ));
      emit(currentState);
    }
  }
}

