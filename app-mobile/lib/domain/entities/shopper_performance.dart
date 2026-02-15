import 'package:equatable/equatable.dart';

enum ShopperRank {
  bronze,
  silver,
  gold,
}

class ShopperPerformance extends Equatable {
  final int completedOrders;
  final double totalEarnings;
  final double totalBonus;
  final double averageRating;
  final int totalRatings;
  final ShopperRank rank;
  final double accuracyScore;
  final int currentStreak;

  const ShopperPerformance({
    required this.completedOrders,
    required this.totalEarnings,
    required this.totalBonus,
    required this.averageRating,
    required this.totalRatings,
    required this.rank,
    required this.accuracyScore,
    required this.currentStreak,
  });

  String get rankLabel {
    switch (rank) {
      case ShopperRank.bronze:
        return 'Bronze';
      case ShopperRank.silver:
        return 'Silver';
      case ShopperRank.gold:
        return 'Gold';
    }
  }

  @override
  List<Object?> get props => [
        completedOrders,
        totalEarnings,
        totalBonus,
        averageRating,
        totalRatings,
        rank,
        accuracyScore,
        currentStreak,
      ];
}


