import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../../domain/entities/product.dart';
import '../models/product_model.dart';

/// Exception personnalisée pour les erreurs API
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Repository pour les produits
class ProductsRepository {
  final String baseUrl = ApiConfig.baseUrl;

  /// Récupère tous les produits avec pagination et filtres
  Future<List<Product>> getProducts({
    int page = 1,
    int pageSize = 100,
    String? category,
    String? search,
    bool? isAvailable,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/products').replace(queryParameters: {
        'page': page.toString(),
        'page_size': pageSize.toString(),
        if (category != null) 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
        if (isAvailable != null) 'is_available': isAvailable.toString(),
      });

      final response = await http
          .get(
            uri,
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final productListResponse = ProductListResponse.fromJson(jsonData);
        return productListResponse.items.map((model) => model.toEntity()).toList();
      } else {
        throw ApiException(
          'Erreur lors de la récupération des produits: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException('Erreur de connexion: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur inattendue: ${e.toString()}');
    }
  }

  /// Récupère un produit par son ID
  Future<Product> getProductById(String productId) async {
    try {
      final uri = Uri.parse('$baseUrl/products/$productId');

      final response = await http
          .get(
            uri,
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final productModel = ProductModel.fromJson(jsonData);
        return productModel.toEntity();
      } else {
        throw ApiException(
          'Erreur lors de la récupération du produit: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException('Erreur de connexion: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur inattendue: ${e.toString()}');
    }
  }

  /// Récupère toutes les catégories disponibles
  Future<List<String>> getCategories() async {
    try {
      final uri = Uri.parse('$baseUrl/products/categories/list');

      final response = await http
          .get(
            uri,
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List<dynamic>;
        return jsonData.map((item) => item.toString()).toList();
      } else {
        throw ApiException(
          'Erreur lors de la récupération des catégories: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException('Erreur de connexion: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur inattendue: ${e.toString()}');
    }
  }
}

