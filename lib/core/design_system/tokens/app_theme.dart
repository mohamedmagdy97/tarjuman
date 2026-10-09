import 'package:flutter/material.dart';
import 'package:tarjuman/core/design_system/tokens/app_colors.dart';
import 'package:tarjuman/core/design_system/tokens/app_radius.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';

abstract final class AppTheme {
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);
  static ThemeData get light => _build(AppColors.light, Brightness.light);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      secondary: c.signal,
      onSecondary: c.bg,
      error: c.error,
      onError: c.bg,
      surface: c.surface,
      onSurface: c.text,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      dividerColor: c.line,
      fontFamily: AppFonts.ui,
      fontFamilyFallback: AppFonts.fallback,
      textTheme: const TextTheme(
        displayMedium: AppTypography.display,
        titleLarge: AppTypography.title,
        titleMedium: AppTypography.heading,
        bodyLarge: AppTypography.body,
        labelLarge: AppTypography.label,
        bodySmall: AppTypography.caption,
      ).apply(bodyColor: c.text, displayColor: c.text),
      extensions: [c],
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      ),
    );
  }
}
