import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../bloc/auth/auth_bloc.dart';
import 'profile_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AuthBloc>().state;
      if (state is AuthAuthenticated && state.user == null) {
        context.read<AuthBloc>().add(const AuthLoadProfile());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            var name = 'Mon compte';
            var subtitle = 'Complète ton profil pour vendre plus vite';

            if (state is AuthAuthenticated) {
              final user = state.user;
              if (user != null) {
                name = user.displayName;
                subtitle = user.locationLabel?.isNotEmpty == true
                    ? user.locationLabel!
                    : state.tokens.phoneNumber;
              }
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                    child: Text('Compte', style: AppTextStyles.h1),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProfilePage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.zero,
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.zero,
                              ),
                              child: Icon(
                                PhosphorIcons.user(),
                                size: 24,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: AppTextStyles.h3),
                                  const SizedBox(height: 4),
                                  Text(subtitle, style: AppTextStyles.bodySecondary),
                                ],
                              ),
                            ),
                            Icon(
                              PhosphorIcons.caretRight(),
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
                    child: Text('Mon espace', style: AppTextStyles.sectionTitle),
                  ),
                ),
                SliverList.list(
                  children: [
                    _TileBlock(
                      icon: PhosphorIcons.handbag(),
                      title: 'Mes achats',
                      subtitle: 'Suivre mes commandes et retraits',
                    ),
                    _TileBlock(
                      icon: PhosphorIcons.storefront(),
                      title: 'Mes ventes',
                      subtitle: 'Voir mes annonces et offres reçues',
                    ),
                    _TileBlock(
                      icon: PhosphorIcons.mapPin(),
                      title: 'Mes box',
                      subtitle: 'Adresses et points de retrait favoris',
                    ),
                    _TileBlock(
                      icon: PhosphorIcons.gear(),
                      title: 'Paramètres',
                      subtitle: 'Préférences, langue et notifications',
                    ),
                  ].map((item) => Padding(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                        child: item,
                      )).toList(),
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

class _TileBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TileBlock({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.zero,
            ),
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.bodySecondary),
              ],
            ),
          ),
          Icon(
            PhosphorIcons.caretRight(),
            size: 18,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
