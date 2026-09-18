import 'package:flutter/material.dart';

/// CliniX color tokens.
///
/// Widgets should almost always read colors from `Theme.of(context)`
/// (via ColorScheme / theme extensions) so dark mode works automatically.
/// This file defines the raw palette used to build those themes.
class AppColors {
  AppColors._();

  // ---- Brand ----
  static const Color primary = Color(0xFF0F4C81);
  static const Color primaryLight = Color(0xFF3E72A6);
  static const Color primaryDark = Color(0xFF0A3559);
  static const Color secondary = Color(0xFF64B5F6);
  static const Color accent = Color(0xFF2AA7A5); // calm teal

  // ---- Semantic ----
  static const Color success = Color(0xFF2E9E6B);
  static const Color warning = Color(0xFFE9A03B);
  static const Color error = Color(0xFFD64545);
  static const Color bloodRed = Color(0xFFE2574C);

  // ---- Neutrals (light) ----
  static const Color background = Color(0xFFF5F8FC);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFEAF1F8);
  static const Color textPrimary = Color(0xFF142233);
  static const Color textSecondary = Color(0xFF5B6B7E);
  static const Color outline = Color(0xFFD5DEE8);

  // ---- Neutrals (dark) ----
  static const Color backgroundDark = Color(0xFF0E1620);
  static const Color surfaceDark = Color(0xFF182230);
  static const Color surfaceVariantDark = Color(0xFF22303F);
  static const Color textPrimaryDark = Color(0xFFEDF2F8);
  static const Color textSecondaryDark = Color(0xFFA7B4C2);
  static const Color outlineDark = Color(0xFF2E3D4E);
}
