import 'package:flutter/material.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const _fontFallbacks = [
    'Noto Sans JP',
    'Noto Sans Thai',
    'Noto Sans Myanmar',
    'Noto Sans SC',
    'Noto Sans TC',
  ];

  static TextStyle get display => TextStyle(
        fontFamily: 'Outfit',
        fontFamilyFallback: _fontFallbacks,
        fontSize: 32,
        fontWeight: FontWeight.w300,
        color: AppColors.sakuraDark,
      );

  static TextStyle get heading1 => TextStyle(
        fontFamily: 'Outfit',
        fontFamilyFallback: _fontFallbacks,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get heading2 => TextStyle(
        fontFamily: 'Outfit',
        fontFamilyFallback: _fontFallbacks,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontFamily: 'Noto Sans',
        fontFamilyFallback: _fontFallbacks,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: 'Noto Sans',
        fontFamilyFallback: _fontFallbacks,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  static TextStyle get label => TextStyle(
        fontFamily: 'Noto Sans',
        fontFamilyFallback: _fontFallbacks,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
      );
}
