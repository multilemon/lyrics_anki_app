import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Primary Palette — Sakura Pink
  static const Color sakura = Color(0xFFE8B4B8);
  static const Color sakuraDark = Color(0xFFC48B8F);
  static const Color sakuraLight = Color(0xFFF2DCDF);

  // Secondary Palette — Warm Wood & Cabin Light (Hokkaido)
  static const Color matcha = Color(0xFFB8A080);
  static const Color matchaDark = Color(0xFF8F7456);
  static const Color peach = Color(0xFFD4C4AB);

  // Neutrals / Backgrounds — Snow-reflected ambient (Hokkaido)
  static const Color background = Color(0xFFF0F2F5);
  static const Color surface = Color(0xFFFAFBFC);
  static const Color white = Color(0xFFFFFFFF);

  // Glassmorphism
  static const Color frost = Color(0xE6FFFFFF); // ~90% opaque white

  // Text Colors — Slate ink (Hokkaido)
  static const Color textPrimary = Color(0xFF2C3642);
  static const Color textSecondary = Color(0xFF5E6E7A);
  static const Color textTertiary = Color(0xFF96A3AD);

  // Functional Colors
  static const Color error = Color(0xFFD47070);
  static const Color success = Color(0xFF81C784);
  static const Color overlay = Color(0x1A000000); // 10% Black
  static const Color border = Color(0xFFDDE2E8);

  // Legacy aliases (for existing code)
  static const Color cream = background;
  static const Color greyLight = border;
}
