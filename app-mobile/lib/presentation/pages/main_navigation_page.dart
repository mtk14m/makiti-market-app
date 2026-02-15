import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/navigation/navigation_bloc.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_page.dart';
import 'shop_page.dart';
import 'cart_page.dart';
import 'account_page.dart';

class MainNavigationPage extends StatelessWidget {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationBloc()..add(NavigateToHome()),
      child: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, state) {
          int currentIndex = 0;
          Widget currentPage = const HomePage();

          if (state is NavigationHome) {
            currentIndex = 0;
            currentPage = const HomePage();
          } else if (state is NavigationShop) {
            currentIndex = 1;
            currentPage = const ShopPage();
          } else if (state is NavigationCart) {
            currentIndex = 2;
            currentPage = const CartPage();
          } else if (state is NavigationAccount) {
            currentIndex = 3;
            currentPage = const AccountPage();
          }

          return Scaffold(
            body: currentPage,
            bottomNavigationBar: BottomNavBar(
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


