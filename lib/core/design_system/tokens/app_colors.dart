import 'package:flutter/material.dart';

/// Brand colour tokens. Values mirror docs/BRAND_GUIDELINES.md §3.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.raised,
    required this.line,
    required this.text,
    required this.muted,
    required this.primary,
    required this.onPrimary,
    required this.primaryText,
    required this.signal,
    required this.info,
    required this.error,
    required this.scrim,
  });

  final Color bg;
  final Color surface;
  final Color raised;
  final Color line;
  final Color text;
  final Color muted;
  final Color primary;
  final Color onPrimary;
  final Color primaryText;
  final Color signal;
  final Color info;
  final Color error;
  final Color scrim;

  static const dark = AppColors(
    bg: Color(0xFF0A0D14),
    surface: Color(0xFF11151F),
    raised: Color(0xFF1A2030),
    line: Color(0xFF262E42),
    text: Color(0xFFEEF1F7),
    muted: Color(0xFF8E98AE),
    primary: Color(0xFFFFC93C),
    onPrimary: Color(0xFF1A1405),
    primaryText: Color(0xFFFFC93C),
    signal: Color(0xFF35D0BA),
    info: Color(0xFF6FA8FF),
    error: Color(0xFFFF6B6B),
    scrim: Color(0xB80A0D14),
  );

  static const light = AppColors(
    bg: Color(0xFFF5F6FA),
    surface: Color(0xFFFFFFFF),
    raised: Color(0xFFECEFF5),
    line: Color(0xFFDCE0EA),
    text: Color(0xFF111827),
    muted: Color(0xFF596277),
    primary: Color(0xFFF5B800),
    onPrimary: Color(0xFF1A1405),
    primaryText: Color(0xFF8A6100),
    signal: Color(0xFF0B8F7F),
    info: Color(0xFF2F6FDB),
    error: Color(0xFFD93A3A),
    scrim: Color(0xB80A0D14),
  );

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? raised,
    Color? line,
    Color? text,
    Color? muted,
    Color? primary,
    Color? onPrimary,
    Color? primaryText,
    Color? signal,
    Color? info,
    Color? error,
    Color? scrim,
  }) => AppColors(
    bg: bg ?? this.bg,
    surface: surface ?? this.surface,
    raised: raised ?? this.raised,
    line: line ?? this.line,
    text: text ?? this.text,
    muted: muted ?? this.muted,
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    primaryText: primaryText ?? this.primaryText,
    signal: signal ?? this.signal,
    info: info ?? this.info,
    error: error ?? this.error,
    scrim: scrim ?? this.scrim,
  );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      raised: l(raised, other.raised),
      line: l(line, other.line),
      text: l(text, other.text),
      muted: l(muted, other.muted),
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      primaryText: l(primaryText, other.primaryText),
      signal: l(signal, other.signal),
      info: l(info, other.info),
      error: l(error, other.error),
      scrim: l(scrim, other.scrim),
    );
  }
}
