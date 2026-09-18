import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// Central theme configuration.
///
/// Every color, radius, button and input style is defined ONCE here.
/// Feature widgets should use `Theme.of(context)` / `ColorScheme` instead of
/// hardcoding colors so light/dark mode stays consistent.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(_lightScheme);

  static ThemeData get dark => _build(_darkScheme);

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDCE9F5),
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFD8F0EF),
    onSecondaryContainer: Color(0xFF0E4F4E),
    tertiary: AppColors.secondary,
    onTertiary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: Color(0xFFFBE3E3),
    onErrorContainer: Color(0xFF7A1E1E),
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.outline,
    outlineVariant: Color(0xFFE5ECF3),
    shadow: Color(0x1A0F4C81),
    inverseSurface: AppColors.textPrimary,
    onInverseSurface: Colors.white,
    inversePrimary: AppColors.secondary,
    surfaceTint: Colors.transparent,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF9CC3E5),
    onPrimary: Color(0xFF0A2A44),
    primaryContainer: Color(0xFF1C3A55),
    onPrimaryContainer: Color(0xFFDCE9F5),
    secondary: Color(0xFF6FC7C5),
    onSecondary: Color(0xFF083534),
    secondaryContainer: Color(0xFF154E4D),
    onSecondaryContainer: Color(0xFFD8F0EF),
    tertiary: Color(0xFF8FB8E8),
    onTertiary: Color(0xFF0A2A44),
    error: Color(0xFFF2A6A6),
    onError: Color(0xFF5C1212),
    errorContainer: Color(0xFF6E2424),
    onErrorContainer: Color(0xFFFBE3E3),
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    surfaceContainerHighest: AppColors.surfaceVariantDark,
    onSurfaceVariant: AppColors.textSecondaryDark,
    outline: AppColors.outlineDark,
    outlineVariant: Color(0xFF22303F),
    shadow: Colors.black54,
    inverseSurface: AppColors.textPrimaryDark,
    onInverseSurface: AppColors.backgroundDark,
    inversePrimary: AppColors.primary,
    surfaceTint: Colors.transparent,
  );

  static ThemeData _build(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme, scheme),
      appBarTheme: AppBarTheme(
        backgroundColor: base.scaffoldBackgroundColor,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0.6,
        shadowColor: scheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(AppSizes.minTouchTarget + 6),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size.fromHeight(AppSizes.minTouchTarget + 4),
          side: BorderSide(color: scheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: scheme.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: _inputBorder(scheme.outlineVariant),
        enabledBorder: _inputBorder(scheme.outlineVariant),
        focusedBorder: _inputBorder(scheme.primary, width: 1.6),
        errorBorder: _inputBorder(scheme.error),
        focusedErrorBorder: _inputBorder(scheme.error, width: 1.6),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  /// Large, readable typography tuned for a healthcare audience.
  static TextTheme _textTheme(TextTheme base, ColorScheme scheme) {
    return base
        .apply(
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
        )
        .copyWith(
          headlineLarge: base.headlineLarge?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: base.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: base.bodyLarge?.copyWith(fontSize: 16, height: 1.4),
          bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, height: 1.4),
          bodySmall: base.bodySmall?.copyWith(
            fontSize: 12,
            height: 1.35,
            color: scheme.onSurfaceVariant,
          ),
        );
  }
}
