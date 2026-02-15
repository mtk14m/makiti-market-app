import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/shopper_wallet.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(WalletInitial()) {
    on<LoadWallet>(_onLoadWallet);
    on<RequestWithdrawal>(_onRequestWithdrawal);
  }

  void _onLoadWallet(LoadWallet event, Emitter<WalletState> emit) {
    emit(WalletLoading());
    
    // TODO: Remplacer par un appel API réel
    final mockWallet = const ShopperWallet(
      balance: 1250.50,
      pendingBalance: 350.00,
      transactions: [],
      totalEarned: 5000.00,
      totalBonus: 750.25,
    );
    
    emit(WalletLoaded(wallet: mockWallet));
  }

  void _onRequestWithdrawal(RequestWithdrawal event, Emitter<WalletState> emit) {
    // TODO: Implémenter la logique de retrait
    if (state is WalletLoaded) {
      emit(WalletWithdrawalRequested(amount: event.amount));
    }
  }
}


