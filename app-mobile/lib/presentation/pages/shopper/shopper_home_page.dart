import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../bloc/shopper/orders/orders_bloc.dart';
import '../../../domain/entities/order.dart';
import '../../widgets/empty_state.dart';
import 'widgets/zone_filter_chip.dart';
import 'widgets/order_card.dart';
import 'negotiation_page.dart';

class ShopperHomePage extends StatefulWidget {
  const ShopperHomePage({super.key});

  @override
  State<ShopperHomePage> createState() => _ShopperHomePageState();
}

class _ShopperHomePageState extends State<ShopperHomePage> {
  MarketZone? selectedZone;

  @override
  void initState() {
    super.initState();
    context.read<OrdersBloc>().add(const LoadOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mode Commando',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nouvelles commandes disponibles',
                        style: AppTextStyles.bodySecondary.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Filtres par zones
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ZoneFilterChip(
                    label: 'Toutes',
                    zone: null,
                    isSelected: selectedZone == null,
                    onTap: () => _selectZone(null),
                  ),
                  const SizedBox(width: 12),
                  ZoneFilterChip(
                    label: 'Zone Rouge',
                    zone: MarketZone.red,
                    isSelected: selectedZone == MarketZone.red,
                    onTap: () => _selectZone(MarketZone.red),
                    color: Colors.red[100]!,
                  ),
                  const SizedBox(width: 12),
                  ZoneFilterChip(
                    label: 'Zone Verte',
                    zone: MarketZone.green,
                    isSelected: selectedZone == MarketZone.green,
                    onTap: () => _selectZone(MarketZone.green),
                    color: Colors.green[100]!,
                  ),
                  const SizedBox(width: 12),
                  ZoneFilterChip(
                    label: 'Zone Sèche',
                    zone: MarketZone.dry,
                    isSelected: selectedZone == MarketZone.dry,
                    onTap: () => _selectZone(MarketZone.dry),
                    color: Colors.orange[100]!,
                  ),
                  const SizedBox(width: 12),
                  ZoneFilterChip(
                    label: 'Divers',
                    zone: MarketZone.misc,
                    isSelected: selectedZone == MarketZone.misc,
                    onTap: () => _selectZone(MarketZone.misc),
                    color: Colors.grey[300]!,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Liste des commandes
            Expanded(
              child: BlocBuilder<OrdersBloc, OrdersState>(
                builder: (context, state) {
                  if (state is OrdersLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (state is OrdersLoaded) {
                    final orders = state.orders
                        .where((order) => order.status == OrderStatus.pending)
                        .toList();

                    if (orders.isEmpty) {
                      return EmptyState(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Aucune commande disponible',
                        subtitle: 'Les nouvelles commandes apparaîtront ici',
                        actionLabel: 'Actualiser',
                        onAction: () {
                          context.read<OrdersBloc>().add(const LoadOrders());
                        },
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: OrderCard(
                            order: orders[index],
                            onAccept: () {
                              if (orders[index].status == OrderStatus.pending) {
                                context.read<OrdersBloc>().add(
                                      AcceptOrder(orders[index].id),
                                    );
                                // Naviguer vers la page de négociation
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => NegotiationPage(
                                      order: orders[index],
                                    ),
                                  ),
                                );
                              } else {
                                // Naviguer vers les détails
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => NegotiationPage(
                                      order: orders[index],
                                    ),
                                  ),
                                );
                              }
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

  void _selectZone(MarketZone? zone) {
    setState(() {
      selectedZone = zone;
    });
    context.read<OrdersBloc>().add(FilterOrdersByZone(zone: zone));
  }
}

