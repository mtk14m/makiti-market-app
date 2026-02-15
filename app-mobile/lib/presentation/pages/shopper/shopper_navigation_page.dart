import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_animations.dart';
import '../../bloc/shopper/orders/orders_bloc.dart';
import '../../bloc/shopper/wallet/wallet_bloc.dart';
import '../../../domain/entities/shopper_performance.dart';
import 'shopper_home_page.dart';
import 'wallet_page.dart';
import 'performance_page.dart';
import 'active_orders_page.dart';
import 'shopper_account_page.dart';
import '../../widgets/shopper_bottom_nav_bar.dart';
import '../../bloc/navigation/navigation_bloc.dart';

class ShopperNavigationPage extends StatelessWidget {
  const ShopperNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => OrdersBloc()..add(const LoadOrders())),
        BlocProvider(create: (_) => WalletBloc()..add(const LoadWallet())),
        BlocProvider(create: (_) => NavigationBloc()..add(NavigateToHome())),
      ],
      child: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, state) {
          int currentIndex = 0;
          Widget currentPage = const ShopperHomePage();

          if (state is NavigationHome) {
            currentIndex = 0;
            currentPage = const ShopperHomePage();
          } else if (state is NavigationShop) {
            currentIndex = 1;
            // Pour shopper, Shop = Wallet
            currentPage = const WalletPage();
          } else if (state is NavigationCart) {
            currentIndex = 2;
            // Pour shopper, Cart = Commandes actives
            currentPage = const ActiveOrdersPage();
          } else if (state is NavigationAccount) {
            currentIndex = 3;
            // Pour shopper, Account = Account page
            currentPage = const ShopperAccountPage();
          }

          return Scaffold(
            body: currentPage,
            bottomNavigationBar: ShopperBottomNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.read<NavigationBloc>().add(NavigateToHome());
                    break;
                  case 1:
                    context.read<NavigationBloc>().add(NavigateToShop());
                    break;
                  case 2:
                    context.read<NavigationBloc>().add(NavigateToCart());
                    break;
                  case 3:
                    context.read<NavigationBloc>().add(NavigateToAccount());
                    break;
                }
              },
            ),
          );
        },
      ),
    );
  }
}

