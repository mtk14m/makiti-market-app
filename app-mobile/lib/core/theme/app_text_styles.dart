import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Inter';

  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double height = 1.2,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _inter({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double height = 1.2,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      textStyle: _base(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      ),
    );
  }

  static final TextStyle h1 = _inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.05,
    letterSpacing: -0.8,
  );

  static final TextStyle h2 = _inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static final TextStyle h3 = _inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.15,
    letterSpacing: -0.25,
  );

  static final TextStyle sectionTitle = _inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.1,
    letterSpacing: -0.35,
  );

  static final TextStyle body = _inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.35,
    letterSpacing: -0.08,
  );

  static final TextStyle bodySecondary = _inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.35,
  );

  static final TextStyle cta = _inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnPrimary,
    height: 1.1,
  );

  static final TextStyle price = _inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.05,
    letterSpacing: -0.3,
  );

  static final TextStyle priceStrikethrough = _inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.0,
  ).copyWith(decoration: TextDecoration.lineThrough);

  static final TextStyle productName = _inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.1,
  );

  static final TextStyle productDescription = _inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.35,
  );
}
