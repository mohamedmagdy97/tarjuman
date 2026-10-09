import 'package:flutter/material.dart';

/// Type scale from docs/BRAND_GUIDELINES.md §4. Colours are applied by the theme.
abstract final class AppFonts {
  static const String ui = 'IBMPlexSansArabic';
  static const String display = 'ReemKufi';
  static const String mono = 'IBMPlexMono';
  static const List<String> fallback = ['Roboto', 'sans-serif'];
}

@immutable
class AppTypography {
  const AppTypography._();

  static const display = TextStyle(
    fontFamily: AppFonts.display,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
  );
  static const title = TextStyle(
    fontFamily: AppFonts.ui,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 22,
    height: 30 / 22,
    fontWeight: FontWeight.w600,
  );
  static const heading = TextStyle(
    fontFamily: AppFonts.ui,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 18,
    height: 26 / 18,
    fontWeight: FontWeight.w600,
  );
  static const body = TextStyle(
    fontFamily: AppFonts.ui,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 16,
    height: 26 / 16,
  );
  static const label = TextStyle(
    fontFamily: AppFonts.ui,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
  );
  static const caption = TextStyle(
    fontFamily: AppFonts.ui,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 12,
    height: 18 / 12,
  );
  static const subtitle = TextStyle(
    fontFamily: AppFonts.ui,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 22,
    height: 32 / 22,
    fontWeight: FontWeight.w500,
  );
  static const timecode = TextStyle(
    fontFamily: AppFonts.mono,
    fontFamilyFallback: ['Menlo', 'monospace'],
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w500,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
