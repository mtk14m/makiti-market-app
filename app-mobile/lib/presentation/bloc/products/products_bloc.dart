import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';
import '../../../data/repositories/products_repository.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductsRepository repository;

  ProductsBloc({ProductsRepository? repository})
      : repository = repository ?? ProductsRepository(),
        super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<FilterProducts>(_onFilterProducts);
    on<SearchProducts>(_onSearchProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsLoading());

    try {
      final products = await repository.getProducts(
        category: event.category,
        search: event.search,
        isAvailable: true,
      );
      emit(ProductsLoaded(products: products));
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
    emit(ProductsLoading());

    try {
      final products = await repository.getProducts(
        category: event.category,
        isAvailable: true,
      );
      emit(ProductsLoaded(products: products));
    } catch (e) {
      emit(ProductsError(
        e is ApiException ? e.message : 'Erreur lors du filtrage des produits',
      ));
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsLoading());

    try {
      final products = await repository.getProducts(
        search: event.query,
        isAvailable: true,
      );
      emit(ProductsLoaded(products: products));
    } catch (e) {
      emit(ProductsError(
        e is ApiException ? e.message : 'Erreur lors de la recherche',
      ));
    }
  }
}


