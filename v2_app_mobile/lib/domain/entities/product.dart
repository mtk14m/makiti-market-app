import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final String? unit;

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

  @override
  List<Object?> get props => [id, name, price, imageUrl, category];
}