import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/search_bar_enhanced.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  static final categories = <_CategoryItem>[
    _CategoryItem('Femmes', PhosphorIcons.tShirt()),
    _CategoryItem('Homme', PhosphorIcons.tShirt()),
    _CategoryItem('Article de créateurs', PhosphorIcons.tag()),
    _CategoryItem('Enfants', PhosphorIcons.baby()),
    _CategoryItem('Maison', PhosphorIcons.house()),
    _CategoryItem('Electronique', PhosphorIcons.power()),
    _CategoryItem('Divertissement', PhosphorIcons.sparkle()),
    _CategoryItem('Animaux', PhosphorIcons.pawPrint()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: SearchBarEnhanced(
                hintText: 'Rechercher un article ou un membre',
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: categories.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.cardBorder),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      minTileHeight: 78,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        category.icon,
                        size: 32,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        category.label,
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Icon(
                        PhosphorIcons.caretRight(),
                        color: AppColors.textTertiary,
                        size: 18,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem {
  final String label;
  final IconData icon;

  const _CategoryItem(this.label, this.icon);
}
