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
                      colors: [c.raised, c.surface],
                    ),
                  ),
                  child: Icon(Icons.play_arrow_rounded, color: c.muted),
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
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    caption,
                    style: AppTypography.caption.copyWith(color: c.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
