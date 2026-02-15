import 'package:flutter/material.dart';

/// Couleurs du design system Makiti
/// Palette sobre inspirée des légumes : vert légume, gris et noir
class AppColors {
  AppColors._();

  // Couleurs Principales - Vert Légume Naturel
  static const Color primary = Color(0xFF6B8E5A); // Vert légume (épinard/brocoli)
  static const Color primaryDark = Color(0xFF4A5D3E); // Vert légume foncé
  static const Color primaryLight = Color(0xFF8FA67F); // Vert légume clair
  static const Color secondary = Color(0xFF2C2C2C); // Noir/gris foncé
  static const Color forestGreen = Color(0xFF3D4A35); // Vert forêt sobre

  // Backgrounds - Tons Neutres
  static const Color backgroundLight = Color(0xFFFAFAFA); // Gris très clair
  static const Color backgroundDark = Color(0xFF1A1A1A); // Noir/gris très foncé
  static const Color backgroundAlt = Color(0xFFF5F5F5); // Gris clair alternatif
  static const Color background = backgroundLight;

  // Surfaces/Cards - Blancs et Gris
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2C2C2C);
  static const Color cardBackground = surfaceLight;
  static const Color cardBorder = Color(0xFFE5E5E5); // Bordure grise subtile

  // Text Colors - Noir et Gris (amélioré pour meilleur contraste)
  static const Color textPrimary = Color(0xFF1A1A1A); // Noir pour texte principal
  static const Color textSecondary = Color(0xFF4A4A4A); // Gris moyen foncé (amélioré pour contraste)
  static const Color textTertiary = Color(0xFF757575); // Gris moyen (amélioré)
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Blanc sur vert
  static const Color textOnDark = Color(0xFFF5F5F5); // Gris clair sur fond sombre

  // Accent Colors - Réduits et Sobres
  static const Color accentYellow = Color(0xFFB8A082); // Beige/jaune terre (au lieu de jaune vif)
  static const Color accentRed = Color(0xFF8B6B5B); // Rouge terre/brique sobre
  static const Color accentGreen = primary; // Utilise le vert légume comme accent

  // Neutrals - Palette Gris/Noir (amélioré pour contraste)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF2C2C2C);
  static const Color mediumGrey = Color(0xFF4A4A4A); // Assombri pour meilleur contraste
  static const Color lightGrey = Color(0xFF757575); // Assombri pour meilleur contraste
  static const Color greyButton = Color(0xFFE5E5E5);
  static const Color greyBorder = Color(0xFFD0D0D0);

  // Variations pour états
  static Color primaryHover = const Color(0xFF5A7A4A); // Vert légume plus foncé au survol
  static Color primaryDisabled = primary.withOpacity(0.4);
  
  // Couleurs spécifiques pour catégories (tons naturels)
  static const Color categoryBg = Color(0xFFE8E8E8); // Fond gris clair pour catégories (assombri pour contraste)
}

