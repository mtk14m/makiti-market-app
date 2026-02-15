import 'package:equatable/equatable.dart';

/// Entité Produit
class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice; // Prix avant réduction
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final String? unit; // kg, pièce, etc.

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isAvailable = true,
    this.unit,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  double? get discountPercentage {
    if (!hasDiscount) return null;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        originalPrice,
        imageUrl,
        category,
        rating,
        reviewCount,
        isAvailable,
        unit,
      ];
}

