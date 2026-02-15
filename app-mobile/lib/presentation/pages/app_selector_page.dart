import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_animations.dart';
import '../widgets/animated_button.dart';
import 'main_navigation_page.dart';
import 'shopper/shopper_navigation_page.dart';

class AppSelectorPage extends StatelessWidget {
  const AppSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Makiti',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choisissez votre mode',
                  style: AppTextStyles.bodySecondary.copyWith(fontSize: 16),
                ),
                AppSpacing.gapXXL,
                
                // Bouton Client
                AnimatedButton(
                  label: 'Mode Client',
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      AppAnimations.fadeRoute(
                        const MainNavigationPage(),
                      ),
                    );
                  },
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  icon: Icons.shopping_cart,
                ),
                
                AppSpacing.gapMD,
                
                // Bouton Shopper
                AnimatedButton(
                  label: 'Mode Shopper',
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      AppAnimations.fadeRoute(
                        const ShopperNavigationPage(),
                      ),
                    );
                  },
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  icon: Icons.shopping_bag,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

