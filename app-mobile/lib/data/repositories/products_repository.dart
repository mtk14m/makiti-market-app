import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../core/errors/api_exception.dart';
import '../../domain/entities/product.dart';
import '../models/product_model.dart';

class ProductPageResult {
  final List<Product> items;
  final int page;
  final int pageSize;
  final int total;
  final int pages;

  const ProductPageResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.pages,
  });

  bool get hasMore => page < pages;
}

/// Repository mobile branche sur le backend commerce Makiti.
/// Les widgets utilisent encore le terme `Product`, mais les donnees
/// proviennent maintenant des `listings` du marketplace C2C.
class ProductsRepository {
  final String baseUrl = ApiConfig.baseUrl;

  /// Recupere les annonces marketplace avec pagination et filtres.
  Future<ProductPageResult> getProductsPage({
    int page = 1,
    int pageSize = 100,
    String? category,
    String? search,
    bool? isAvailable,
  }) async {
    try {
      final queryParameters = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
        if (category != null) 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
      };
      if (isAvailable == true) {
        queryParameters['status'] = 'published';
      }

      final uri = Uri.parse('$baseUrl/commerce/listings').replace(
        queryParameters: queryParameters,
      );
      debugPrint('[ProductsRepository] GET $uri');

      final response = await http
          .get(
            uri,
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
      debugPrint(
        '[ProductsRepository] GET $uri -> ${response.statusCode} ${response.body}',
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final productListResponse = ProductListResponse.fromJson(jsonData);
        return ProductPageResult(
          items: productListResponse.items.map((model) => model.toEntity()).toList(),
          page: productListResponse.page,
          pageSize: productListResponse.pageSize,
          total: productListResponse.total,
          pages: productListResponse.pages,
        );
      } else {
        throw ApiException(
          message:
              'Erreur lors de la recuperation des annonces: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      debugPrint('[ProductsRepository] ClientException: ${e.message}');
      throw ApiException(message: 'Erreur de connexion: ${e.message}');
    } catch (e) {
      debugPrint('[ProductsRepository] Error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Erreur inattendue: ${e.toString()}');
    }
  }

  Future<List<Product>> getProducts({
    int page = 1,
    int pageSize = 100,
    String? category,
    String? search,
    bool? isAvailable,
  }) async {
    final result = await getProductsPage(
      page: page,
      pageSize: pageSize,
      category: category,
      search: search,
      isAvailable: isAvailable,
    );
    return result.items;
  }

  /// Recupere une annonce par son identifiant.
  Future<Product> getProductById(String productId) async {
    try {
      final uri = Uri.parse('$baseUrl/commerce/listings/$productId');
      debugPrint('[ProductsRepository] GET $uri');

      final response = await http
          .get(
            uri,
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
      debugPrint(
        '[ProductsRepository] GET $uri -> ${response.statusCode} ${response.body}',
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final productModel = ProductModel.fromJson(jsonData);
        return productModel.toEntity();
      } else {
        throw ApiException(
          message:
              'Erreur lors de la recuperation de l\'annonce: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      debugPrint('[ProductsRepository] ClientException: ${e.message}');
      throw ApiException(message: 'Erreur de connexion: ${e.message}');
    } catch (e) {
      debugPrint('[ProductsRepository] Error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Erreur inattendue: ${e.toString()}');
    }
  }

  /// Construit la liste des categories depuis les annonces publiees.
  Future<List<String>> getCategories() async {
    final products = await getProducts(page: 1, pageSize: 100, isAvailable: true);
    final categories = products.map((product) => product.category).toSet().toList();
    categories.sort();
    return categories;
  }
}
