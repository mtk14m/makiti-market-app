import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Helper pour gérer le cache des images
class ImageCacheHelper {
  ImageCacheHelper._();

  /// Cache manager personnalisé avec durée de vie réduite
  static final CacheManager imageCacheManager = CacheManager(
    Config(
      'makiti_images',
      stalePeriod: const Duration(days: 1), // Images mises à jour après 1 jour
      maxNrOfCacheObjects: 200, // Maximum 200 images en cache
      repo: JsonCacheInfoRepository(databaseName: 'makiti_images'),
    ),
  );

  /// Vide le cache des images
  static Future<void> clearImageCache() async {
    await imageCacheManager.emptyCache();
  }

  /// Supprime une image spécifique du cache
  static Future<void> removeImageFromCache(String url) async {
    await imageCacheManager.removeFile(url);
  }

  /// Obtient le fichier depuis le cache
  static Future<FileInfo?> getCachedImage(String url) async {
    return await imageCacheManager.getFileFromCache(url);
  }
}

