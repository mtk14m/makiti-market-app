import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../bloc/shopper/wallet/wallet_bloc.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Portefeuille',
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.history),
                    onPressed: () {
                      // TODO: Voir l'historique
                    },
                  ),
                ],
              ),
            ),

            // Contenu
            Expanded(
              child: BlocBuilder<WalletBloc, WalletState>(
                builder: (context, state) {
                  if (state is WalletLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is WalletLoaded) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Solde principal
                          Card(
                            color: AppColors.primaryDark,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Text(
                                    'Solde disponible',
                                    style: AppTextStyles.bodySecondary.copyWith(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                                        .format(state.wallet.balance),
                                    style: AppTextStyles.h1.copyWith(
                                      fontSize: 36,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (state.wallet.pendingBalance > 0) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.pending, color: Colors.white70, size: 16),
                                          const SizedBox(width: 8),
                                          Text(
                                            'En attente: ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(state.wallet.pendingBalance)}',
                                            style: AppTextStyles.body.copyWith(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Statistiques
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Total gagné',
                                  state.wallet.totalEarned,
                                  Icons.trending_up,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Bonus négociation',
                                  state.wallet.totalBonus,
                                  Icons.stars,
                                  AppColors.primary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Bouton retrait
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                _showWithdrawalDialog(context, state.wallet.balance);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.textOnPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('Demander un retrait'),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Transactions récentes
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Transactions récentes',
                              style: AppTextStyles.sectionTitle,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (state.wallet.transactions.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 48,
                                    color: AppColors.textSecondary.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucune transaction',
                                    style: AppTextStyles.bodySecondary,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
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

  Widget _buildStatCard(String label, double value, IconData icon, Color color) {
    return Card(
      color: AppColors.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value),
              style: AppTextStyles.price.copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdrawalDialog(BuildContext context, double balance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demande de retrait'),
        content: Text(
          'Votre solde disponible: ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(balance)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<WalletBloc>().add(RequestWithdrawal(balance));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Demande de retrait envoyée'),
                ),
              );
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}

