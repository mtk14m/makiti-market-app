import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../bloc/products/products_bloc.dart';
import 'product_detail_page.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_grid_card.dart';
import '../widgets/search_bar_enhanced.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  static const List<String> _filters = [
    'Tout',
    'Mode',
    'Chaussures',
    'Beauty',
    'Tech',
    'Maison',
  ];

  String _selectedFilter = _filters.first;

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(const LoadProducts());
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });

    if (filter == 'Tout') {
      context.read<ProductsBloc>().add(const LoadProducts());
    } else {
      context.read<ProductsBloc>().add(SearchProducts(filter));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catalogue',
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SearchBarEnhanced(
                      hintText: 'Rechercher une annonce...',
                      onChanged: (value) {
                        if (value.isEmpty) {
                          context.read<ProductsBloc>().add(const LoadProducts());
                        } else {
                          context.read<ProductsBloc>().add(SearchProducts(value));
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final filter = _filters[index];
                          return _ExploreFilterChip(
                            label: filter,
                            selected: _selectedFilter == filter,
                            onTap: () => _applyFilter(filter),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BlocBuilder<ProductsBloc, ProductsState>(
              builder: (context, state) {
                if (state is ProductsLoading) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (state is ProductsError) {
                  return SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.error_outline,
                      title: 'Erreur de chargement',
                      subtitle: state.message,
                    ),
                  );
                }

                if (state is ProductsLoaded) {
                  if (state.products.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: EmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'Aucune annonce trouvee',
                        subtitle: 'Essaie une autre recherche ou un autre filtre.',
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = state.products[index];
                          return ProductGridCard(
                            product: item,
                            onPrimaryAction: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailPage(
                                    product: item,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        childCount: state.products.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.66,
                      ),
                    ),
                  );
                }

                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ExploreFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primaryDark : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySecondary.copyWith(
            fontSize: 12,
            color: selected ? AppColors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
