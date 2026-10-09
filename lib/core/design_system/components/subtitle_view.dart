import 'package:flutter/material.dart';
import 'package:tarjuman/core/design_system/tokens/app_motion.dart';
import 'package:tarjuman/core/design_system/tokens/app_radius.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_style.dart';

extension SubtitleColorValue on SubtitleColorPreset {
  Color get value => switch (this) {
    SubtitleColorPreset.white => const Color(0xFFFFFFFF),
    SubtitleColorPreset.saffron => const Color(0xFFFFC93C),
    SubtitleColorPreset.lagoon => const Color(0xFF35D0BA),
    SubtitleColorPreset.softGrey => const Color(0xFFD6DAE4),
  };
}

/// Renders one cue. Stateless: knows nothing about the player.
class SubtitleView extends StatelessWidget {
  const SubtitleView({required this.text, required this.style, super.key});

  final String? text;
  final SubtitleStyle style;

  @override
  Widget build(BuildContext context) {
    final color = style.color.value;
    final base = AppTypography.subtitle.copyWith(
      fontSize: style.fontSize,
      color: color,
      height: 1.45,
    );
    final outline = style.background == SubtitleBackground.outline;

    return AnimatedSwitcher(
      duration: AppMotion.cue,
      child: text == null
          ? const SizedBox.shrink(key: ValueKey('none'))
          : DecoratedBox(
              key: ValueKey(text),
              decoration: BoxDecoration(
                color: style.background == SubtitleBackground.box
                    ? context.colors.scrim
                    : null,
                borderRadius: AppRadius.mdAll,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(
                  text!,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: outline
                      ? base.copyWith(
                          shadows: const [
                            Shadow(blurRadius: 3),
                            Shadow(blurRadius: 6),
                          ],
                        )
                      : base,
                ),
              ),
            ),
    );
  }
}
