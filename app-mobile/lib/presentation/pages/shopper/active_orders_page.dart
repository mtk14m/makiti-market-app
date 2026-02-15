import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../bloc/shopper/orders/orders_bloc.dart';
import '../../../domain/entities/order.dart';
import '../../widgets/empty_state.dart';
import 'widgets/order_card.dart';
import 'negotiation_page.dart';

class ActiveOrdersPage extends StatelessWidget {
  const ActiveOrdersPage({super.key});

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
                  Text(
                    'Mes commandes actives',
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),

            // Liste des commandes actives
            Expanded(
              child: BlocBuilder<OrdersBloc, OrdersState>(
                builder: (context, state) {
                  if (state is OrdersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is OrdersLoaded) {
                    final activeOrders = state.orders
                        .where((order) => 
                            order.status == OrderStatus.accepted ||
                            order.status == OrderStatus.shopping)
                        .toList();

                    if (activeOrders.isEmpty) {
                      return EmptyState(
                        icon: Icons.check_circle_outline,
                        title: 'Aucune commande active',
                        subtitle: 'Acceptez une commande pour commencer',
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: activeOrders.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: OrderCard(
                            order: activeOrders[index],
                            onAccept: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => NegotiationPage(
                                    order: activeOrders[index],
                                  ),
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
            ),
          ],
        ),
      ),
    );
  }
}

