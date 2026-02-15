part of 'wallet_bloc.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWallet extends WalletEvent {
  const LoadWallet();
}

class RequestWithdrawal extends WalletEvent {
  final double amount;

  const RequestWithdrawal(this.amount);

  @override
  List<Object?> get props => [amount];
}


