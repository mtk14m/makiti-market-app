import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/auth_tokens_model.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';

class AuthStorageService {
  static const String _tokensKey = 'auth_tokens';
  static const String _roleKey = 'user_role';
  static const String _userKey = 'auth_user';

  /// Sauvegarder les tokens d'authentification
  Future<void> saveTokens(AuthTokens tokens) async {
    await saveSession(tokens);
  }

  /// Sauvegarder les tokens + user (session complète)
  Future<void> saveSession(AuthTokens tokens, {User? user}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokensJson = jsonEncode({
        'access_token': tokens.accessToken,
        'refresh_token': tokens.refreshToken,
        'token_type': tokens.tokenType,
        'user_id': tokens.userId,
        'role': tokens.role,
        'phone_number': tokens.phoneNumber,
        'is_new_user': tokens.isNewUser,
      });
      await prefs.setString(_tokensKey, tokensJson);
      await prefs.setString(_roleKey, tokens.role);
      if (user != null) {
        final userJson = jsonEncode(UserModel.fromEntity(user).toJson());
        await prefs.setString(_userKey, userJson);
      }
      // Log uniquement pour debug
      // print('Tokens sauvegardés avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des tokens: $e');
      rethrow;
    }
  }

  /// Récupérer les tokens d'authentification
  Future<AuthTokens?> getTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokensJson = prefs.getString(_tokensKey);
      if (tokensJson == null) {
        // Pas de log pour les cas normaux (utilisateur non connecté)
        return null;
      }

      final data = jsonDecode(tokensJson) as Map<String, dynamic>;
      final tokens = AuthTokensModel.fromJson(data);
      // Log uniquement en cas de succès de récupération (pour debug)
      // print('Tokens récupérés avec succès pour l\'utilisateur: ${tokens.userId}');
      return tokens;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des tokens: $e');
      return null;
    }
  }

  /// Recuperer le role de l'utilisateur
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  /// Récupérer l'utilisateur stocké
  Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson == null) {
        return null;
      }
      final data = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  /// Vérifier si l'utilisateur est authentifié
  Future<bool> isAuthenticated() async {
    final tokens = await getTokens();
    return tokens != null;
  }

  /// Supprimer les tokens (déconnexion)
  Future<void> clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokensKey);
      await prefs.remove(_roleKey);
      await prefs.remove(_userKey);
      // Log uniquement pour debug
      // print('Tokens supprimés avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la suppression des tokens: $e');
      rethrow;
    }
  }
}

