import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Makiti Market'),
      ),
      body: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenue !', style: AppTextStyles.h1),
            AppSpacing.gapMD,
            Text(
              'Tout ce dont vous avez besoin pour vos courses.',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}