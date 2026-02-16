/// Helper pour gérer les URLs d'images avec cache busting
class ImageUrlHelper {
  ImageUrlHelper._();

  /// Ajoute un paramètre de version à l'URL pour forcer le rechargement
  /// Utilise l'ID du produit comme version pour que chaque produit ait son propre cache
  static String addCacheBuster(String url, String productId) {
    if (url.isEmpty) return url;
    
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    
    // Ajoute un paramètre v avec l'ID du produit pour forcer le rechargement
    // Si l'URL change, le cache sera invalidé automatiquement
    final updatedQuery = Map<String, String>.from(uri.queryParameters);
    updatedQuery['v'] = productId; // Version basée sur l'ID du produit
    
    return uri.replace(queryParameters: updatedQuery).toString();
  }

  /// Nettoie l'URL en retirant les paramètres de cache
  static String cleanUrl(String url) {
    if (url.isEmpty) return url;
    
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    
    final cleanedQuery = Map<String, String>.from(uri.queryParameters);
    cleanedQuery.remove('v'); // Retire le paramètre de version
    
    return uri.replace(queryParameters: cleanedQuery).toString();
  }
}

