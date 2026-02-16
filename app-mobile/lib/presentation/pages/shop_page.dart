import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../bloc/products/products_bloc.dart';
import '../bloc/cart/cart_bloc.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/search_bar_enhanced.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';
import '../../core/theme/app_animations.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(const LoadProducts());
    selectedCategory = null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Boutique',
          style: AppTextStyles.h2.copyWith(color: AppColors.primaryDark),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barre de recherche améliorée
            Padding(
              padding: AppSpacing.paddingHorizontalLG,
              child: BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  // Générer les suggestions dynamiques basées sur les produits disponibles
                  List<String> getDynamicSuggestions(String query) {
                    if (state is ProductsLoaded) {
                      final queryLower = query.toLowerCase();
                      // Extraire les noms de produits qui correspondent à la requête
                      final matchingProducts = state.products
                          .where((product) => product.name.toLowerCase().contains(queryLower))
                          .map((product) => product.name)
                          .toSet() // Éviter les doublons
                          .toList();
                      
                      // Trier par pertinence (produits qui commencent par la requête en premier)
                      matchingProducts.sort((a, b) {
                        final aStartsWith = a.toLowerCase().startsWith(queryLower);
                        final bStartsWith = b.toLowerCase().startsWith(queryLower);
                        if (aStartsWith && !bStartsWith) return -1;
                        if (!aStartsWith && bStartsWith) return 1;
                        return a.compareTo(b);
                      });
                      
                      return matchingProducts;
                    }
                    return [];
                  }

                  return SearchBarEnhanced(
                    hintText: 'Rechercher des produits...',
                    onChanged: (value) {
                      if (value.isEmpty) {
                        // Si la recherche est vide, recharger les produits avec le filtre de catégorie actuel
                        context.read<ProductsBloc>().add(FilterProducts(category: selectedCategory));
                      } else {
                        // Sinon, rechercher (la recherche ignore le filtre de catégorie)
                        context.read<ProductsBloc>().add(SearchProducts(value));
                      }
                    },
                    dynamicSuggestions: getDynamicSuggestions,
                  );
                },
              ),
            ),
            
            AppSpacing.gapMD,

            // Catégories filtres
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: AppSpacing.paddingHorizontalLG,
                children: [
                  CategoryChip(
                    label: 'Tout',
                    icon: Icons.apps,
                    isSelected: selectedCategory == null,
                    onTap: () => _selectCategory(null),
                  ),
                  SizedBox(width: AppSpacing.md - AppSpacing.xs),
                  CategoryChip(
                    label: 'Légumes',
                    icon: Icons.eco,
                    isSelected: selectedCategory == 'Légumes',
                    onTap: () => _selectCategory('Légumes'),
                  ),
                  SizedBox(width: AppSpacing.md - AppSpacing.xs),
                  CategoryChip(
                    label: 'Fruits',
                    icon: Icons.apple,
                    isSelected: selectedCategory == 'Fruits',
                    onTap: () => _selectCategory('Fruits'),
                  ),
                  SizedBox(width: AppSpacing.md - AppSpacing.xs),
                  CategoryChip(
                    label: 'Viande',
                    icon: Icons.set_meal,
                    isSelected: selectedCategory == 'Viande',
                    onTap: () => _selectCategory('Viande'),
                  ),
                  SizedBox(width: AppSpacing.md - AppSpacing.xs),
                  CategoryChip(
                    label: 'Épicerie',
                    icon: Icons.shopping_bag,
                    isSelected: selectedCategory == 'Épicerie',
                    onTap: () => _selectCategory('Épicerie'),
                  ),
                  SizedBox(width: AppSpacing.md - AppSpacing.xs),
                  CategoryChip(
                    label: 'Produits laitiers',
                    icon: Icons.agriculture,
                    isSelected: selectedCategory == 'Produits laitiers',
                    onTap: () => _selectCategory('Produits laitiers'),
                  ),
                  SizedBox(width: AppSpacing.md - AppSpacing.xs),
                  CategoryChip(
                    label: 'Boissons',
                    icon: Icons.local_drink,
                    isSelected: selectedCategory == 'Boissons',
                    onTap: () => _selectCategory('Boissons'),
                  ),
                ],
              ),
            ),

            AppSpacing.gapMD,

            // Section Header
            SectionHeader(
              title: 'Produits',
              subtitle: selectedCategory != null 
                  ? 'Catégorie : $selectedCategory' 
                  : 'Tous les produits',
            ),
            
            AppSpacing.gapSM,

            // Liste des produits
            Expanded(
              child: BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  if (state is ProductsLoading) {
                    return const Center(
                      child: Padding(
                        padding: AppSpacing.paddingXL,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (state is ProductsError) {
                    return Center(
                      child: Padding(
                        padding: AppSpacing.paddingXL,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              'Erreur',
                              style: AppTextStyles.h2,
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              state.message,
                              style: AppTextStyles.bodySecondary,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: AppSpacing.lg),
                            ElevatedButton(
                              onPressed: () {
                                context.read<ProductsBloc>().add(const LoadProducts());
                              },
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (state is ProductsLoaded) {
                    if (state.products.isEmpty) {
                      return EmptyState(
                        icon: Icons.search_off,
                        title: 'Aucun produit trouvé',
                        subtitle: 'Essayez une autre recherche ou catégorie',
                      );
                    }
                    return ListView.builder(
                      padding: AppSpacing.paddingHorizontalLG,
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.md),
                          child: ProductCard(
                            product: state.products[index],
                            onAddToCart: () {
                              context.read<CartBloc>().add(
                                    AddToCart(state.products[index]),
                                  );
                              context.showAnimatedSnackBar(
                                '${state.products[index].name} ajouté au panier',
                                backgroundColor: AppColors.primaryDark,
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectCategory(String? category) {
    setState(() {
      selectedCategory = category;
    });
    context.read<ProductsBloc>().add(FilterProducts(category: category));
  }
}

