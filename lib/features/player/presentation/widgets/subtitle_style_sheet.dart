import 'package:flutter/material.dart';
import 'package:tarjuman/core/design_system/components/app_segmented.dart';
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
                height: 120,
                child: Center(
                  child: SubtitleView(
                    text: l10n.preview,
                    original: 'This is how subtitles will look',
                    style: style,
                  ),
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
            AppSegmented<SubtitleBackground>(
              options: {
                SubtitleBackground.box: l10n.bgBox,
                SubtitleBackground.outline: l10n.bgOutline,
                SubtitleBackground.none: l10n.bgNone,
              },
              value: style.background,
              onChanged: (v) => onChanged(style.copyWith(background: v)),
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.showOriginal),
              value: style.showOriginal,
              onChanged: (v) => onChanged(style.copyWith(showOriginal: v)),
            ),
            const SizedBox(height: AppSpacing.md),
            _label(context, l10n.position),
            const SizedBox(height: AppSpacing.sm),
            AppSegmented<SubtitlePosition>(
              options: {
                SubtitlePosition.bottom: l10n.posBottom,
                SubtitlePosition.top: l10n.posTop,
              },
              value: style.position,
              onChanged: (v) => onChanged(style.copyWith(position: v)),
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
