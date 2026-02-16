import 'dart:io';

/// Configuration de l'API
class ApiConfig {
  ApiConfig._();

  // URL de base de l'API
  // Pour iOS simulator: localhost fonctionne
  // Pour Android emulator: utiliser 10.0.2.2 au lieu de localhost
  // Pour device physique: utiliser l'IP locale de votre machine (ex: 192.168.1.100)
  static String get baseUrl {
    // Détection automatique de la plateforme
    if (Platform.isAndroid) {
      // Android emulator utilise 10.0.2.2 pour accéder à localhost de la machine hôte
      return 'http://10.0.2.2:8000/api/v1';
    } else {
      // iOS simulator et autres plateformes
      return 'http://localhost:8000/api/v1';
    }
  }
  
  // Timeout pour les requêtes HTTP (en secondes)
  static const int timeoutSeconds = 30;
  
  // Headers par défaut
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}

