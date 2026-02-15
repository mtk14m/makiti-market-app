import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc() : super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<FilterProducts>(_onFilterProducts);
    on<SearchProducts>(_onSearchProducts);
  }

  void _onLoadProducts(LoadProducts event, Emitter<ProductsState> emit) {
    emit(ProductsLoading());
    
    // TODO: Remplacer par un appel API réel
    // Pour l'instant, on utilise des données mock
    final mockProducts = _getMockProducts();
    
    emit(ProductsLoaded(products: mockProducts));
  }

  void _onFilterProducts(FilterProducts event, Emitter<ProductsState> emit) {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      final filtered = event.category == null
          ? currentState.products
          : currentState.products
              .where((p) => p.category == event.category)
              .toList();

      emit(ProductsLoaded(products: filtered));
    }
  }

  void _onSearchProducts(SearchProducts event, Emitter<ProductsState> emit) {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      final query = event.query.toLowerCase();
      final filtered = currentState.products
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query))
          .toList();

      emit(ProductsLoaded(products: filtered));
    }
  }

  List<Product> _getMockProducts() {
    // Données mock pour la maquette - Produits du marché ouest-africain
    // Prix en FCFA (1 USD ≈ 600 FCFA)
    return [
      const Product(
        id: '1',
        name: 'Tomates fraîches',
        description: 'Tomates rouges du marché',
        price: 1500, // 1.5k FCFA pour 1kg
        imageUrl: '',
        category: 'Légumes',
        rating: 4.5,
        reviewCount: 120,
        unit: 'kg',
      ),
      const Product(
        id: '2',
        name: 'Oignons',
        description: 'Oignons locaux',
        price: 1200, // 1.2k FCFA pour 1kg
        imageUrl: '',
        category: 'Légumes',
        rating: 4.8,
        reviewCount: 89,
        unit: 'kg',
      ),
      const Product(
        id: '3',
        name: 'Pommes de terre',
        description: 'Pommes de terre fraîches',
        price: 1800, // 1.8k FCFA pour 1kg
        originalPrice: 2000,
        imageUrl: '',
        category: 'Légumes',
        rating: 4.6,
        reviewCount: 156,
        unit: 'kg',
      ),
      const Product(
        id: '4',
        name: 'Mangues',
        description: 'Mangues sucrées de saison',
        price: 2500, // 2.5k FCFA pour 1kg
        imageUrl: '',
        category: 'Fruits',
        rating: 4.7,
        reviewCount: 203,
        unit: 'kg',
      ),
      const Product(
        id: '5',
        name: 'Bananes plantain',
        description: 'Bananes plantain mûres',
        price: 1000, // 1k FCFA pour 1kg
        imageUrl: '',
        category: 'Fruits',
        rating: 4.5,
        reviewCount: 178,
        unit: 'kg',
      ),
      const Product(
        id: '6',
        name: 'Riz local',
        description: 'Riz de qualité supérieure',
        price: 3500, // 3.5k FCFA pour 1kg
        imageUrl: '',
        category: 'Épicerie',
        rating: 4.9,
        reviewCount: 245,
        unit: 'kg',
      ),
      const Product(
        id: '7',
        name: 'Huile de palme',
        description: 'Huile de palme naturelle',
        price: 2800, // 2.8k FCFA pour 1L
        imageUrl: '',
        category: 'Épicerie',
        rating: 4.6,
        reviewCount: 167,
        unit: 'L',
      ),
      const Product(
        id: '8',
        name: 'Poulet frais',
        description: 'Poulet fermier',
        price: 4500, // 4.5k FCFA pour 1kg
        imageUrl: '',
        category: 'Viande',
        rating: 4.8,
        reviewCount: 198,
        unit: 'kg',
      ),
    ];
  }
}


