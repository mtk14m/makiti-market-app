import '../../domain/entities/product.dart';

/// Modele de donnees pour les annonces marketplace.
/// On conserve l'entite `Product` cote mobile pour eviter une refonte UI
/// immediate, mais les donnees viennent maintenant de `/commerce/listings`.
class ProductModel {
  final String id;
  final String name;
  final String? description;
  final double price;
  final double? originalPrice;
  final String? imageUrl;
  final String category;
  final bool isAvailable;
  final String? unit;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.originalPrice,
    this.imageUrl,
    required this.category,
    this.isAvailable = true,
    this.unit,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final photoUrlsRaw = json['photo_urls'];
    final photoUrls = photoUrlsRaw is List
        ? photoUrlsRaw.whereType<String>().toList()
        : const <String>[];
    final coverImageUrl = json['cover_image_url'] as String?;
    final legacyImageUrl = json['image_url'] as String?;
    final resolvedImageUrl = coverImageUrl ??
        legacyImageUrl ??
        (photoUrls.isNotEmpty ? photoUrls.first : null);
    final title = (json['title'] ?? json['name'] ?? '') as String;
    final status = (json['status'] as String?)?.toLowerCase();

    return ProductModel(
      id: json['id'] as String,
      name: title,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['original_price'] != null
          ? (json['original_price'] as num).toDouble()
          : null,
      imageUrl: resolvedImageUrl,
      category: json['category'] as String,
      isAvailable: json['is_available'] as bool? ?? status == 'published',
      unit: (json['brand'] ?? json['size'] ?? json['condition'] ?? json['unit'])
          as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'image_url': imageUrl,
      'category': category,
      'is_available': isAvailable,
      'unit': unit,
    };
  }

  /// Convertit le modèle en entité Product
  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description ?? '',
      price: price,
      originalPrice: originalPrice,
      imageUrl: imageUrl ?? '',
      category: category,
      rating: 0.0,
      reviewCount: 0,
      isAvailable: isAvailable,
      unit: unit,
    );
  }
}

/// Modèle pour la réponse de liste de produits
class ProductListResponse {
  final List<ProductModel> items;
  final int total;
  final int page;
  final int pageSize;
  final int pages;

  ProductListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.pages,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      items: (json['items'] as List<dynamic>)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
      pages: json['pages'] as int,
    );
  }
}
