import 'package:flutter/material.dart';
import 'package:tarjuman/core/design_system/components/status_pill.dart';
import 'package:tarjuman/core/design_system/tokens/app_radius.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({
    required this.title,
    required this.pillLabel,
    required this.pillTone,
    required this.caption,
    required this.onTap,
    this.onLongPress,
    this.isFavorite = false,
    this.onFavorite,
    this.favoriteTooltip,
    this.durationLabel,
    super.key,
  });

  final String title;
  final String pillLabel;
  final PillTone pillTone;
  final String caption;
  final String? durationLabel;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isFavorite;
  final VoidCallback? onFavorite;
  final String? favoriteTooltip;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: AppRadius.mdAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.mdAll,
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.topEnd,
                      end: AlignmentDirectional.bottomStart,
                      colors: _thumbColors(title),
                    ),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white70,
                          size: 30,
                        ),
                      ),
                      if (durationLabel != null)
                        PositionedDirectional(
                          end: 6,
                          bottom: 5,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: .62),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  durationLabel!,
                                  style: AppTypography.timecode.copyWith(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    style: AppTypography.label.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  StatusPill(label: pillLabel, tone: pillTone),
                  if (caption.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      caption,
                      style: AppTypography.caption.copyWith(color: c.muted),
                    ),
                  ],
                ],
              ),
            ),
            if (onFavorite != null)
              IconButton(
                tooltip: favoriteTooltip,
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isFavorite ? c.primary : c.muted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Deterministic per-title gradient so the list has visual rhythm until real
/// frame thumbnails exist.
List<Color> _thumbColors(String seed) {
  final hue =
      (seed.codeUnits.fold<int>(7, (a, b) => (a * 31 + b) & 0xffff) % 360)
          .toDouble();
  return [
    HSLColor.fromAHSL(1, hue, .45, .30).toColor(),
    HSLColor.fromAHSL(1, (hue + 40) % 360, .50, .12).toColor(),
  ];
}
