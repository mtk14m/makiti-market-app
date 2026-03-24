import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../../core/errors/api_exception.dart';
import '../../domain/entities/auth_tokens.dart';
import '../models/auth_tokens_model.dart';

/// Extrait le message d'erreur du body JSON (format FastAPI)
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

class AuthRepository {
  /// Send OTP (unified for login/register)
  Future<String> sendOTP({
    required String phoneNumber,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/send-otp');
    debugPrint('[AuthRepository] POST $url');

    final response = await http
        .post(
          url,
          headers: ApiConfig.defaultHeaders,
          body: jsonEncode({'phone_number': phoneNumber}),
        )
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
    debugPrint(
      '[AuthRepository] POST $url -> ${response.statusCode} ${response.body}',
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['otp_code'] as String? ?? '';
      } catch (e) {
        throw ApiException(
          message: 'Erreur de parsing',
          statusCode: response.statusCode,
          detail: 'Réponse invalide du serveur',
        );
      }
    }

    throw ApiException(
      message: 'Erreur lors de l\'envoi du code OTP',
      statusCode: response.statusCode,
      detail: _parseErrorDetail(
        response.body,
        'Erreur ${response.statusCode}',
      ),
    );
  }

  /// Verify OTP and check if user exists
  Future<Map<String, dynamic>> verifyOTP({
    required String phoneNumber,
    required String otpCode,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/verify-otp');
    debugPrint('[AuthRepository] POST $url');

    final response = await http
        .post(
          url,
          headers: ApiConfig.defaultHeaders,
          body: jsonEncode({
            'phone_number': phoneNumber,
            'otp_code': otpCode,
          }),
        )
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
    debugPrint(
      '[AuthRepository] POST $url -> ${response.statusCode} ${response.body}',
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'user_exists': data['user_exists'] as bool,
          'role': data['role'] as String?,
          'phone_number': data['phone_number'] as String,
        };
      } catch (e) {
        throw ApiException(
          message: 'Erreur de parsing',
          statusCode: response.statusCode,
          detail: 'Réponse invalide du serveur',
        );
      }
    }

    throw ApiException(
      message: 'Code OTP invalide',
      statusCode: response.statusCode,
      detail: _parseErrorDetail(
        response.body,
        'Code OTP invalide ou expiré',
      ),
    );
  }

  /// Login existing user after OTP verification
  Future<AuthTokens> login({
    required String phoneNumber,
    required String otpCode,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');
    debugPrint('[AuthRepository] POST $url');

    final response = await http
        .post(
          url,
          headers: ApiConfig.defaultHeaders,
          body: jsonEncode({
            'phone_number': phoneNumber,
            'otp_code': otpCode,
          }),
        )
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
    debugPrint(
      '[AuthRepository] POST $url -> ${response.statusCode} ${response.body}',
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthTokensModel.fromJson(data);
      } catch (e) {
        throw ApiException(
          message: 'Erreur de parsing',
          statusCode: response.statusCode,
          detail: 'Réponse invalide du serveur',
        );
      }
    }

    throw ApiException(
      message: 'Erreur lors de la connexion',
      statusCode: response.statusCode,
      detail: _parseErrorDetail(response.body, 'Connexion échouée'),
    );
  }

  /// Register new user after OTP verification
  Future<AuthTokens> register({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String country,
    required String city,
    String role = 'buyer_seller',
    String? email,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? language,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/register');
    debugPrint('[AuthRepository] POST $url');

    final body = <String, dynamic>{
      'phone_number': phoneNumber,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'country': country,
      'city': city,
    };
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (dateOfBirth != null) {
      body['date_of_birth'] = dateOfBirth.toIso8601String().split('T')[0];
    }
    if (gender != null && gender.isNotEmpty) body['gender'] = gender;
    if (address != null && address.isNotEmpty) body['address'] = address;
    if (language != null && language.isNotEmpty) body['language'] = language;

    final response = await http
        .post(
          url,
          headers: ApiConfig.defaultHeaders,
          body: jsonEncode(body),
        )
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
    debugPrint(
      '[AuthRepository] POST $url -> ${response.statusCode} ${response.body}',
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthTokensModel.fromJson(data);
      } catch (e) {
        throw ApiException(
          message: 'Erreur de parsing',
          statusCode: response.statusCode,
          detail: 'Réponse invalide du serveur',
        );
      }
    }

    throw ApiException(
      message: 'Erreur lors de l\'inscription',
      statusCode: response.statusCode,
      detail: _parseErrorDetail(response.body, 'Inscription échouée'),
    );
  }

  /// Refresh access token using refresh token
  Future<AuthTokens> refreshToken(String refreshToken) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/refresh');
    debugPrint('[AuthRepository] POST $url');

    final response = await http
        .post(
          url,
          headers: ApiConfig.defaultHeaders,
          body: jsonEncode({'refresh_token': refreshToken}),
        )
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
    debugPrint(
      '[AuthRepository] POST $url -> ${response.statusCode} ${response.body}',
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthTokensModel.fromJson(data);
      } catch (e) {
        throw ApiException(
          message: 'Erreur de parsing',
          statusCode: response.statusCode,
          detail: 'Réponse invalide du serveur',
        );
      }
    }

    throw ApiException(
      message: 'Refresh token échoué',
      statusCode: response.statusCode,
      detail: _parseErrorDetail(
        response.body,
        'Session expirée. Veuillez vous reconnecter.',
      ),
    );
  }

  /// Get current user profile
  /// [accessToken] : token JWT actuel
  ///
  /// En cas de 401, on pourrait implémenter un refresh automatique ici.
  /// Pour l'instant on lance ApiException et le Bloc gère la déconnexion si besoin.
  Future<Map<String, dynamic>> getProfile(String accessToken) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/me');
    debugPrint('[AuthRepository] GET $url');

    final headers = {
      ...ApiConfig.defaultHeaders,
      'Authorization': 'Bearer $accessToken',
    };

    final response = await http
        .get(url, headers: headers)
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
    debugPrint(
      '[AuthRepository] GET $url -> ${response.statusCode} ${response.body}',
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } catch (e) {
        throw ApiException(
          message: 'Erreur de parsing',
          statusCode: response.statusCode,
          detail: 'Réponse invalide du serveur',
        );
      }
    }

    throw ApiException(
      message: 'Erreur lors de la récupération du profil',
      statusCode: response.statusCode,
      detail: _parseErrorDetail(
        response.body,
        response.statusCode == 401
            ? 'Session expirée. Veuillez vous reconnecter.'
            : 'Impossible de charger le profil',
      ),
    );
  }

  /// Update current user profile
  Future<Map<String, dynamic>> updateProfile(
    String accessToken, {
    String? firstName,
    String? lastName,
    String? email,
    DateTime? dateOfBirth,
    String? gender,
    String? country,
    String? city,
    String? address,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/me');

    final headers = {
      ...ApiConfig.defaultHeaders,
      'Authorization': 'Bearer $accessToken',
    };

    final body = <String, dynamic>{};
    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;
    if (email != null) body['email'] = email;
    if (dateOfBirth != null) {
      body['date_of_birth'] = dateOfBirth.toIso8601String().split('T')[0];
    }
    if (gender != null) body['gender'] = gender;
    if (country != null) body['country'] = country;
    if (city != null) body['city'] = city;
    if (address != null) body['address'] = address;

    final response = await http
        .patch(
          url,
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } catch (e) {
        throw ApiException(
          message: 'Erreur de parsing',
          statusCode: response.statusCode,
          detail: 'Réponse invalide du serveur',
        );
      }
    }

    throw ApiException(
      message: 'Erreur lors de la mise à jour du profil',
      statusCode: response.statusCode,
      detail: _parseErrorDetail(
        response.body,
        'Impossible de mettre à jour le profil',
      ),
    );
  }
}
