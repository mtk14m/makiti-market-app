import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/order.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc() : super(OrdersInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<AcceptOrder>(_onAcceptOrder);
    on<StartShopping>(_onStartShopping);
    on<CompleteOrder>(_onCompleteOrder);
    on<FilterOrdersByZone>(_onFilterOrdersByZone);
  }

  void _onLoadOrders(LoadOrders event, Emitter<OrdersState> emit) {
    emit(OrdersLoading());
    
    // TODO: Remplacer par un appel API réel
    final mockOrders = _getMockOrders();
    
    emit(OrdersLoaded(orders: mockOrders));
  }

  void _onAcceptOrder(AcceptOrder event, Emitter<OrdersState> emit) {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      final updatedOrders = currentState.orders.map((order) {
        if (order.id == event.orderId) {
          return Order(
            id: order.id,
            clientId: order.clientId,
            clientName: order.clientName,
            items: order.items,
            type: order.type,
            status: OrderStatus.accepted,
            createdAt: order.createdAt,
            estimatedDelivery: order.estimatedDelivery,
            totalAmount: order.totalAmount,
            deliveryAddress: order.deliveryAddress,
            itemsByZone: order.itemsByZone,
          );
        }
        return order;
      }).toList();

      emit(OrdersLoaded(orders: updatedOrders));
    }
  }

  void _onStartShopping(StartShopping event, Emitter<OrdersState> emit) {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      final updatedOrders = currentState.orders.map((order) {
        if (order.id == event.orderId) {
          return Order(
            id: order.id,
            clientId: order.clientId,
            clientName: order.clientName,
            items: order.items,
            type: order.type,
            status: OrderStatus.shopping,
            createdAt: order.createdAt,
            estimatedDelivery: order.estimatedDelivery,
            totalAmount: order.totalAmount,
            deliveryAddress: order.deliveryAddress,
            itemsByZone: order.itemsByZone,
          );
        }
        return order;
      }).toList();

      emit(OrdersLoaded(orders: updatedOrders));
    }
  }

  void _onCompleteOrder(CompleteOrder event, Emitter<OrdersState> emit) {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      final updatedOrders = currentState.orders
          .where((order) => order.id != event.orderId)
          .toList();

      emit(OrdersLoaded(orders: updatedOrders));
    }
  }

  void _onFilterOrdersByZone(FilterOrdersByZone event, Emitter<OrdersState> emit) {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      final filtered = event.zone == null
          ? currentState.orders
          : currentState.orders.where((order) {
              return order.itemsByZone.containsKey(event.zone);
            }).toList();

      emit(OrdersLoaded(orders: filtered));
    }
  }

  List<Order> _getMockOrders() {
    return [
      Order(
        id: '1',
        clientId: 'c1',
        clientName: 'Marie Diallo',
        items: [
          const OrderItem(
            id: 'i1',
            productId: 'p1',
            productName: 'Tomates',
            quantity: 2,
            targetPrice: 2.50,
            zone: MarketZone.green,
            unit: 'kg',
          ),
          const OrderItem(
            id: 'i2',
            productId: 'p2',
            productName: 'Oignons',
            quantity: 1,
            targetPrice: 1.50,
            zone: MarketZone.green,
            unit: 'kg',
          ),
        ],
        type: OrderType.classic,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        estimatedDelivery: DateTime.now().add(const Duration(hours: 2)),
        totalAmount: 6.50,
        deliveryAddress: 'Cocody, Abidjan',
        itemsByZone: {
          MarketZone.green: [
            const OrderItem(
              id: 'i1',
              productId: 'p1',
              productName: 'Tomates',
              quantity: 2,
              targetPrice: 2.50,
              zone: MarketZone.green,
              unit: 'kg',
            ),
            const OrderItem(
              id: 'i2',
              productId: 'p2',
              productName: 'Oignons',
              quantity: 1,
              targetPrice: 1.50,
              zone: MarketZone.green,
              unit: 'kg',
            ),
          ],
        },
      ),
    ];
  }
}


