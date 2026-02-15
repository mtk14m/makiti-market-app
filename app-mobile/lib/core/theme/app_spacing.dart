import 'package:flutter/material.dart';

/// Système d'espacement cohérent pour l'application Makiti
/// Basé sur un système de 8px (8-point grid system)
class AppSpacing {
  AppSpacing._();

  // Espacements de base (multiples de 8)
  static const double xs = 4.0;   // 0.5 * 8
  static const double sm = 8.0;   // 1 * 8
  static const double md = 16.0;  // 2 * 8
  static const double lg = 24.0;  // 3 * 8
  static const double xl = 32.0;  // 4 * 8
  static const double xxl = 48.0; // 6 * 8

  // Padding standards
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  // Padding horizontaux
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(horizontal: xl);

  // Padding verticaux
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: lg);

  // Marges standards
  static const EdgeInsets marginXS = EdgeInsets.all(xs);
  static const EdgeInsets marginSM = EdgeInsets.all(sm);
  static const EdgeInsets marginMD = EdgeInsets.all(md);
  static const EdgeInsets marginLG = EdgeInsets.all(lg);
  static const EdgeInsets marginXL = EdgeInsets.all(xl);

  // Espacements entre éléments
  static const SizedBox gapXS = SizedBox(height: xs, width: xs);
  static const SizedBox gapSM = SizedBox(height: sm, width: sm);
  static const SizedBox gapMD = SizedBox(height: md, width: md);
  static const SizedBox gapLG = SizedBox(height: lg, width: lg);
  static const SizedBox gapXL = SizedBox(height: xl, width: xl);
  static const SizedBox gapXXL = SizedBox(height: xxl, width: xxl);
}

/// Extension pour faciliter l'utilisation des espacements
extension SpacingExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  bool get isSmallScreen => screenWidth < 375;
  bool get isMediumScreen => screenWidth >= 375 && screenWidth < 768;
  bool get isLargeScreen => screenWidth >= 768;
}


