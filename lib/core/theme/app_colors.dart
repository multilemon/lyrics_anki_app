import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Primary Palette
  static const Color sakura = Color(0xFFE8B4B8);
  static const Color sakuraDark = Color(0xFFD4A5A5);
  static const Color sakuraLight = Color(0xFFF2DCDF);

  // Secondary Palette
  static const Color matcha = Color(0xFFA3C9A8);
  static const Color matchaDark = Color(0xFF84A98C);

  // Neutrals / Backgrounds
  // A warm, paper-like cream for main backgrounds
  static const Color cream = Color(0xFFF9F6F7);
  static const Color white = Color(0xFFFFFFFF);

  // Text Colors
  // Do not use pure black (#000000). Use deep browns or charcoals.
  static const Color textPrimary = Color(0xFF5D4037); // Deep warm brown
  static const Color textSecondary = Color(0xFF8E7F7F); // Muted mauve-brown
  static const Color textTertiary = Color(0xFFBCAAA4);

  // Functional Colors
  static const Color error = Color(0xFFE57373);
  static const Color success = Color(0xFF81C784);
  static const Color overlay = Color(0x1A000000); // 10% Black
}
