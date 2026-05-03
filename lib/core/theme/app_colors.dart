import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Primary Palette — Warm Amber (stage lights / paper lanterns)
  static const Color sakura = Color(0xFFE8A87C);
  static const Color sakuraDark = Color(0xFFD4935A);
  static const Color sakuraLight = Color(0xFFF5D5B0);

  // Accent — Cherry Blossom pop
  static const Color accent = Color(0xFFD4749C);
  static const Color accentLight = Color(0xFFE8A0BD);

  // Secondary Palette — Deep Indigo (aizome)
  static const Color matcha = Color(0xFF3D5A80);
  static const Color matchaDark = Color(0xFF2B4060);
  static const Color peach = Color(0xFF5B8ABF);

  // Neutrals / Backgrounds — Tokyo midnight
  static const Color background = Color(0xFF0D1B2A);
  static const Color surface = Color(0xFF1B2838);
  static const Color surfaceLight = Color(0xFF243447);
  static const Color white = Color(0xFFE8E4DF);

  // Glassmorphism
  static const Color frost = Color(0x1AFFFFFF); // ~10% opaque white on dark

  // Text Colors — Warm neutrals on dark
  static const Color textPrimary = Color(0xFFE8E4DF);
  static const Color textSecondary = Color(0xFF8B9EC7);
  static const Color textTertiary = Color(0xFF5A6F8A);

  // Functional Colors
  static const Color error = Color(0xFFE06060);
  static const Color success = Color(0xFF6BCB77);
  static const Color overlay = Color(0x33000000); // 20% Black
  static const Color border = Color(0xFF2E4259);

  // Legacy aliases (for existing code)
  static const Color cream = background;
  static const Color greyLight = border;
}
