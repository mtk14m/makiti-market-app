import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/product.dart';
import '../bloc/navigation/navigation_bloc.dart';
import '../bloc/products/products_bloc.dart';
import '../widgets/product_grid_card.dart';
import '../widgets/search_bar_enhanced.dart';
import 'product_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const tabs = ['Voir tout', 'Articles de créateurs', 'Electronique'];
  String selectedTab = tabs.first;

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(const LoadProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: BlocBuilder<ProductsBloc, ProductsState>(
          builder: (context, state) {
            final products = state is ProductsLoaded ? state.products : const <Product>[];

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: SearchBarEnhanced(
                      hintText: 'Rechercher un article ou un membre',
                      onTap: () =>
                          context.read<NavigationBloc>().add(NavigateToExplore()),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                    child: SizedBox(
                      height: 38,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: tabs.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 34),
                        itemBuilder: (context, index) {
                          final tab = tabs[index];
                          final selected = tab == selectedTab;
                          return GestureDetector(
                            onTap: () => setState(() => selectedTab = tab),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tab,
                                  style: AppTextStyles.body.copyWith(
                                    color: selected
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                    fontWeight: selected
                                        ? FontWeight.w500
                                        : FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
                                  height: 2,
                                  width: selected ? 70 : 0,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Recommandé pour toi',
                                style: AppTextStyles.h1.copyWith(fontSize: 28),
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.read<NavigationBloc>().add(NavigateToExplore()),
                              child: Text(
                                'Tout voir',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Une sélection de pièces visibles tout de suite, avec prix et protection inclus.',
                          style: AppTextStyles.bodySecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                if (state is ProductsLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (state is ProductsError)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: AppColors.surfaceLight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Impossible de charger les articles',
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              style: AppTextStyles.bodySecondary.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () => context.read<ProductsBloc>().add(
                                      const LoadProducts(),
                                    ),
                                child: const Text('Réessayer'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (products.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: AppColors.surfaceLight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aucun article publié pour le moment',
                              style: AppTextStyles.h3,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Le backend répond peut-être, mais il ne renvoie encore aucun listing publié.',
                              style: AppTextStyles.bodySecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = products[index];
                          return ProductGridCard(
                            product: product,
                            onPrimaryAction: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailPage(product: product),
                                ),
                              );
                            },
                          );
                        },
                        childCount: products.length > 6 ? 6 : products.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 24,
                        childAspectRatio: 0.58,
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Container(
                      height: 166,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8B59E),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NOUVEAU',
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 13,
                                    color: AppColors.white,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Découvre la mode\nde luxe',
                                  style: AppTextStyles.h2.copyWith(
                                    color: AppColors.white,
                                    height: 1.2,
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 180,
                                  height: 44,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.white,
                                      foregroundColor: AppColors.textPrimary,
                                      minimumSize: Size.zero,
                                      padding: EdgeInsets.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: Text(
                                      'Acheter maintenant',
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: -12,
                            bottom: 0,
                            child: Icon(
                              PhosphorIcons.handbag(),
                              size: 120,
                              color: AppColors.white.withValues(alpha: 0.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            );
          },
        ),
      ),
    );
  }
}
