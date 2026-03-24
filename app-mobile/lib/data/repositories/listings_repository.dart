import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../core/errors/api_exception.dart';

String _parseErrorDetail(String body, String fallback) {
  try {
    final error = jsonDecode(body) as Map<String, dynamic>;
    final detail = error['detail'];
    if (detail is String) return detail;
    if (detail is List && detail.isNotEmpty) {
      return detail.first.toString();
    }
    return fallback;
  } catch (_) {
    return body.isNotEmpty ? body : fallback;
  }
}

class ListingsRepository {
  Future<String> uploadListingImage(
    String accessToken,
    File imageFile,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/commerce/listings/upload-image');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamed = await request.send().timeout(
          Duration(seconds: ApiConfig.timeoutSeconds),
        );
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['url'] as String;
      } catch (_) {
        throw ApiException(
          message: 'Erreur de parsing',
          statusCode: response.statusCode,
          detail: 'Réponse invalide du serveur',
        );
      }
    }

    throw ApiException(
      message: 'Erreur lors de l\'upload',
      statusCode: response.statusCode,
      detail: _parseErrorDetail(
        response.body,
        'Impossible d\'envoyer cette image',
      ),
    );
  }

  Future<Map<String, dynamic>> createListing(
    String accessToken, {
    required String title,
    required String description,
    required double price,
    required String category,
    required List<String> photoUrls,
    String? brand,
    String? size,
    required String condition,
    required String parcelSize,
    required bool isNegotiable,
    String currency = 'XOF',
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/commerce/listings');
    final headers = {
      ...ApiConfig.defaultHeaders,
      'Authorization': 'Bearer $accessToken',
    };

    final body = <String, dynamic>{
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'category': category,
      'condition': condition,
      'parcel_size': parcelSize,
      'is_negotiable': isNegotiable,
      'photo_urls': photoUrls,
    };
    if (photoUrls.isNotEmpty) {
      body['cover_image_url'] = photoUrls.first;
    }

    if (brand != null && brand.isNotEmpty) body['brand'] = brand;
    if (size != null && size.isNotEmpty) body['size'] = size;

    final response = await http
        .post(
          url,
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        throw ApiException(
          message: 'Erreur de parsing',
          statusCode: response.statusCode,
          detail: 'Réponse invalide du serveur',
        );
      }
    }

    throw ApiException(
      message: 'Erreur lors de la publication',
      statusCode: response.statusCode,
      detail: _parseErrorDetail(
        response.body,
        'Impossible de publier cette annonce',
      ),
    );
  }
}
