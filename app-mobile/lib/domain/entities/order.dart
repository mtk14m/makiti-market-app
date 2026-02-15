import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending,
  accepted,
  shopping,
  completed,
  cancelled,
}

enum OrderType {
  classic, // 2h
  flash, // 1h
}

enum MarketZone {
  red, // Boucherie/Poissonnerie
  green, // Maraîchers
  dry, // Céréales/Épicerie
  misc, // Divers
}

class Order extends Equatable {
  final String id;
  final String clientId;
  final String clientName;
  final List<OrderItem> items;
  final OrderType type;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final double totalAmount;
  final String deliveryAddress;
  final Map<MarketZone, List<OrderItem>> itemsByZone;

  const Order({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.items,
    required this.type,
    required this.status,
    required this.createdAt,
    this.estimatedDelivery,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.itemsByZone,
  });

  int get estimatedTimeMinutes {
    return type == OrderType.flash ? 60 : 120;
  }

  @override
  List<Object?> get props => [
        id,
        clientId,
        clientName,
        items,
        type,
        status,
        createdAt,
        estimatedDelivery,
        totalAmount,
        deliveryAddress,
        itemsByZone,
      ];
}

class OrderItem extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double targetPrice;
  final double? negotiatedPrice;
  final MarketZone zone;
  final String? unit;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.targetPrice,
    this.negotiatedPrice,
    required this.zone,
    this.unit,
  });

  bool get isNegotiated => negotiatedPrice != null;

  double get savings {
    if (negotiatedPrice == null) return 0;
    return (targetPrice - negotiatedPrice!) * quantity;
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        quantity,
        targetPrice,
        negotiatedPrice,
        zone,
        unit,
      ];
}


