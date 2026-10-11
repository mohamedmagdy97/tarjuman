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

/// Colours for speaker tags 1..4 (0 = untagged, uses the style colour).
const speakerColors = <Color>[
  Color(0xFFFFC93C),
  Color(0xFF35D0BA),
  Color(0xFFFF8A9B),
  Color(0xFF7DB7FF),
];

Color? speakerColor(int speaker) =>
    speaker >= 1 && speaker <= speakerColors.length
    ? speakerColors[speaker - 1]
    : null;

/// Renders one cue. Stateless: knows nothing about the player.
class SubtitleView extends StatelessWidget {
  const SubtitleView({
    required this.text,
    required this.style,
    this.original,
    this.speaker = 0,
    super.key,
  });

  final String? text;

  /// Speaker tag; non-zero overrides the style colour for this line.
  final int speaker;

  /// English source line, shown above the Arabic when the style asks for it.
  final String? original;

  final SubtitleStyle style;

  @override
  Widget build(BuildContext context) {
    final color = speakerColor(speaker) ?? style.color.value;
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (style.showOriginal && original != null)
                      Text(
                        original!,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.ltr,
                        style: base.copyWith(
                          fontSize: style.fontSize * .68,
                          color: color.withValues(alpha: .72),
                        ),
                      ),
                    Text(
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
                  ],
                ),
              ),
            ),
    );
  }
}
