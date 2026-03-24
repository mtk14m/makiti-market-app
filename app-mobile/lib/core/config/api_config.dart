import 'dart:io';

/// Configuration de l'API Makiti
///
/// CONCEPT : Centraliser la config pour éviter les URLs en dur.
/// baseUrlOverride permet de tester sur device physique (téléphone réel).
class ApiConfig {
  ApiConfig._();

  /// Remplace l'URL automatique si défini.
  /// À utiliser pour tester sur device physique :
  ///   ApiConfig.baseUrlOverride = 'http://192.168.1.100:8000/api/v1';
  /// Puis flutter run sur ton téléphone connecté au même réseau WiFi.
  static String? baseUrlOverride;

  /// URL de base de l'API
  ///
  /// - iOS simulator : localhost fonctionne (le simu partage le réseau du Mac)
  /// - Android emulator : 10.0.2.2 = localhost de la machine hôte
  /// - Device physique : utiliser baseUrlOverride avec l'IP de ton Mac
  static String get baseUrl {
    if (baseUrlOverride != null && baseUrlOverride!.isNotEmpty) {
      return baseUrlOverride!;
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/v1';
    } else {
      return 'http://127.0.0.1:8000/api/v1';
    }
  }

  /// Timeout pour les requêtes HTTP (en secondes)
  static const int timeoutSeconds = 30;

  /// Headers par défaut pour toutes les requêtes API
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
