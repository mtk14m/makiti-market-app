import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../bloc/products/products_bloc.dart';
import '../bloc/cart/cart_bloc.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/promotion_card.dart';
import '../widgets/delivery_header.dart';
import '../widgets/search_bar_enhanced.dart';
import '../widgets/section_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(const LoadProducts());
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Delivery Header
            const DeliveryHeader(),
            
            // Barre de recherche améliorée
            Padding(
              padding: AppSpacing.paddingHorizontalLG,
              child: SearchBarEnhanced(
                hintText: 'Rechercher des produits...',
                suggestions: const [
                  'Tomates',
                  'Oignons',
                  'Pommes de terre',
                  'Riz',
                  'Huile',
                ],
              ),
            ),
            
            AppSpacing.gapMD,
            
            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Catégories horizontales
                    SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: AppSpacing.paddingHorizontalLG,
                        children: [
                          CategoryChip(
                            label: 'Légumes',
                            icon: Icons.eco,
                            isSelected: selectedCategory == 'Légumes',
                            onTap: () => _selectCategory('Légumes'),
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                          ),
                          SizedBox(width: AppSpacing.lg),
                          CategoryChip(
                            label: 'Fruits',
                            icon: Icons.apple,
                            isSelected: selectedCategory == 'Fruits',
                            onTap: () => _selectCategory('Fruits'),
                            backgroundColor: AppColors.categoryBg,
                          ),
                          SizedBox(width: AppSpacing.lg),
                          CategoryChip(
                            label: 'Viande',
                            icon: Icons.set_meal,
                            isSelected: selectedCategory == 'Viande',
                            onTap: () => _selectCategory('Viande'),
                            backgroundColor: AppColors.categoryBg,
                          ),
                          SizedBox(width: AppSpacing.lg),
                          CategoryChip(
                            label: 'Poisson',
                            icon: Icons.set_meal,
                            isSelected: selectedCategory == 'Poisson',
                            onTap: () => _selectCategory('Poisson'),
                            backgroundColor: AppColors.categoryBg,
                          ),
                          SizedBox(width: AppSpacing.lg),
                          CategoryChip(
                            label: 'Épicerie',
                            icon: Icons.shopping_basket,
                            isSelected: selectedCategory == 'Épicerie',
                            onTap: () => _selectCategory('Épicerie'),
                            backgroundColor: AppColors.categoryBg,
                          ),
                        ],
                      ),
                    ),

                    AppSpacing.gapMD,

                    // Section "Hot this week!"
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: 'À ne pas manquer !',
                          onActionTap: () {},
                        ),
                        AppSpacing.gapMD,
                        SizedBox(
                          height: 160,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: AppSpacing.paddingHorizontalLG,
                            children: const [
                              PromotionCard(
                                title: 'Livraison gratuite',
                                subtitle: 'Profitez de la livraison gratuite sur toutes vos commandes',
                              ),
                              SizedBox(width: 16),
                              PromotionCard(
                                title: '15% sur votre première commande',
                                subtitle: 'Utilisez le code PREMIER pour bénéficier de la réduction',
                                discount: 15,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.gapXL,

                    // Section "Best for you"
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: 'Pour vous',
                          onActionTap: () {},
                        ),
                        AppSpacing.gapMD,
                        // Filtres horizontaux
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: AppSpacing.paddingHorizontalLG,
                            children: [
                                _buildFilterChip('Sélection', true),
                                SizedBox(width: AppSpacing.sm),
                                _buildFilterChip('Nouveautés', false),
                                SizedBox(width: AppSpacing.sm),
                                _buildFilterChip('Essentiels', false),
                                SizedBox(width: AppSpacing.sm),
                                _buildFilterChip('Promotions', false),
                            ],
                          ),
                        ),
                        AppSpacing.gapMD,
                        // Liste de produits
                        BlocBuilder<ProductsBloc, ProductsState>(
                          builder: (context, state) {
                            if (state is ProductsLoading) {
                              return const Center(
                                child: Padding(
                                  padding: AppSpacing.paddingXL,
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (state is ProductsLoaded) {
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: state.products.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      left: AppSpacing.paddingHorizontalLG.horizontal / 2,
                                      right: AppSpacing.paddingHorizontalLG.horizontal / 2,
                                      bottom: AppSpacing.md,
                                    ),
                                    child: ProductCard(
                                      product: state.products[index],
                                      onAddToCart: () {
                                        context.read<CartBloc>().add(
                                              AddToCart(state.products[index]),
                                            );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${state.products[index].name} ajouté au panier',
                                            ),
                                            duration: const Duration(seconds: 1),
                                          ),
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
                      ],
                    ),

                    SizedBox(height: AppSpacing.xxl + AppSpacing.xl), // Espace pour la bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: Implémenter le changement de filtre
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  void _selectCategory(String? category) {
    setState(() {
      selectedCategory = selectedCategory == category ? null : category;
    });
    context.read<ProductsBloc>().add(FilterProducts(category: selectedCategory));
  }
}

