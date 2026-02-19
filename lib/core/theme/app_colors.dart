import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Primary Palette — Sakura Pink (kept)
  static const Color sakura = Color(0xFFE8B4B8);
  static const Color sakuraDark = Color(0xFFD4A5A5);
  static const Color sakuraLight = Color(0xFFF2DCDF);

  // Secondary Palette — Warm Wood & Cabin Light (Hokkaido)
  static const Color matcha = Color(0xFFB8A080);
  static const Color matchaDark = Color(0xFF8F7456);
  static const Color peach = Color(0xFFD4C4AB);

  // Neutrals / Backgrounds — Snow-reflected ambient (Hokkaido)
  static const Color cream = Color(0xFFF5F7FA);
  static const Color white = Color(0xFFFFFFFF);

  // Glassmorphism
  static const Color frost = Color(0xCCF5F7FA); // ~80% opaque snow

  // Text Colors — Slate ink (Hokkaido)
  static const Color textPrimary = Color(0xFF3B4856);
  static const Color textSecondary = Color(0xFF7A8A96);
  static const Color textTertiary = Color(0xFFA8B5BF);

  // Functional Colors
  static const Color error = Color(0xFFD47070);
  static const Color success = Color(0xFF81C784);
  static const Color overlay = Color(0x1A000000); // 10% Black
  static const Color greyLight = Color(0xFFE4E9ED); // Light grey for borders
}
