import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static TextStyle get display => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w300,
        color: AppColors.sakuraDark,
      );

  static TextStyle get heading1 => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get heading2 => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.notoSansJp(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.notoSansJp(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  static TextStyle get label => GoogleFonts.notoSansJp(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
      );
}
