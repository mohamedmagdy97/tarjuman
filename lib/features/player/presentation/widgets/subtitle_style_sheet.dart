import 'package:flutter/material.dart';
import 'package:tarjuman/core/design_system/components/subtitle_view.dart';
import 'package:tarjuman/core/design_system/tokens/app_radius.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_style.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

class SubtitleStyleSheet extends StatelessWidget {
  const SubtitleStyleSheet({
    required this.style,
    required this.onChanged,
    super.key,
  });

  final SubtitleStyle style;
  final ValueChanged<SubtitleStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.subtitleStyle, style: AppTypography.heading),
            const SizedBox(height: AppSpacing.lg),
            DecoratedBox(
              decoration: BoxDecoration(
                color: c.bg,
                borderRadius: AppRadius.mdAll,
              ),
              child: SizedBox(
                height: 84,
                child: Center(
                  child: SubtitleView(text: l10n.preview, style: style),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _label(context, l10n.size),
            Slider(
              value: style.fontSize,
              min: SubtitleStyle.minFontSize,
              max: SubtitleStyle.maxFontSize,
              divisions: 10,
              label: style.fontSize.round().toString(),
              activeColor: c.primary,
              onChanged: (v) => onChanged(style.copyWith(fontSize: v)),
            ),
            _label(context, l10n.colour),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                for (final p in SubtitleColorPreset.values)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 10),
                    child: Semantics(
                      button: true,
                      selected: style.color == p,
                      label: p.name,
                      child: GestureDetector(
                        onTap: () => onChanged(style.copyWith(color: p)),
                        child: SizedBox.square(
                          dimension: 48,
                          child: Center(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: p.value,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: style.color == p ? c.primary : c.line,
                                  width: style.color == p ? 3 : 2,
                                ),
                              ),
                              child: const SizedBox.square(dimension: 34),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _label(context, l10n.background),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<SubtitleBackground>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: SubtitleBackground.box,
                  label: Text(l10n.bgBox),
                ),
                ButtonSegment(
                  value: SubtitleBackground.outline,
                  label: Text(l10n.bgOutline),
                ),
                ButtonSegment(
                  value: SubtitleBackground.none,
                  label: Text(l10n.bgNone),
                ),
              ],
              selected: {style.background},
              onSelectionChanged: (s) =>
                  onChanged(style.copyWith(background: s.first)),
            ),
            const SizedBox(height: AppSpacing.md),
            _label(context, l10n.position),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<SubtitlePosition>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: SubtitlePosition.bottom,
                  label: Text(l10n.posBottom),
                ),
                ButtonSegment(
                  value: SubtitlePosition.top,
                  label: Text(l10n.posTop),
                ),
              ],
              selected: {style.position},
              onSelectionChanged: (s) =>
                  onChanged(style.copyWith(position: s.first)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Text(
    text,
    style: AppTypography.caption.copyWith(
      color: context.colors.muted,
      fontWeight: FontWeight.w600,
    ),
  );
}
