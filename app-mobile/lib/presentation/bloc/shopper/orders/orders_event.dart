part of 'orders_bloc.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrdersEvent {
  const LoadOrders();
}

class AcceptOrder extends OrdersEvent {
  final String orderId;

  const AcceptOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class StartShopping extends OrdersEvent {
  final String orderId;

  const StartShopping(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class CompleteOrder extends OrdersEvent {
  final String orderId;

  const CompleteOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class FilterOrdersByZone extends OrdersEvent {
  final MarketZone? zone;

  const FilterOrdersByZone({this.zone});

  @override
  List<Object?> get props => [zone];
}


