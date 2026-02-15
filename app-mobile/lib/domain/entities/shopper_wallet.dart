import 'package:equatable/equatable.dart';

class ShopperWallet extends Equatable {
  final double balance;
  final double pendingBalance;
  final List<WalletTransaction> transactions;
  final double totalEarned;
  final double totalBonus;

  const ShopperWallet({
    required this.balance,
    required this.pendingBalance,
    required this.transactions,
    required this.totalEarned,
    required this.totalBonus,
  });

  double get totalAvailable => balance + pendingBalance;

  @override
  List<Object?> get props => [
        balance,
        pendingBalance,
        transactions,
        totalEarned,
        totalBonus,
      ];
}

class WalletTransaction extends Equatable {
  final String id;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String description;
  final String? orderId;

  const WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    required this.description,
    this.orderId,
  });

  @override
  List<Object?> get props => [id, amount, type, date, description, orderId];
}

enum TransactionType {
  credit,
  debit,
  bonus,
  withdrawal,
}


