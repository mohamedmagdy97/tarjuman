import 'package:flutter/material.dart';
import 'package:tarjuman/core/design_system/tokens/app_radius.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';

class CueTile extends StatelessWidget {
  const CueTile({
    required this.timecode,
    required this.text,
    required this.onTap,
    required this.onEdit,
    this.original,
    this.edited = false,
    this.editedLabel = '',
    this.speakerColor,
    this.flags = const [],
    super.key,
  });

  final String timecode;
  final String text;
  final String? original;
  final bool edited;
  final String editedLabel;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  /// Colour bar at the start edge when the line has a speaker tag.
  final Color? speakerColor;

  /// Short review warnings shown under the text.
  final List<String> flags;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: c.raised,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 4, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (speakerColor != null)
                  Container(
                    width: 4,
                    height: 36,
                    margin: const EdgeInsetsDirectional.only(end: 10),
                    decoration: BoxDecoration(
                      color: speakerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      timecode,
                      style: AppTypography.timecode.copyWith(
                        fontSize: 12,
                        color: c.muted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (original != null)
                        Text(
                          original!,
                          textDirection: TextDirection.ltr,
                          style: AppTypography.caption.copyWith(color: c.muted),
                        ),
                      Text(
                        text,
                        style: AppTypography.body.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (flags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Wrap(
                            spacing: 6,
                            children: [
                              for (final f in flags)
                                Text(
                                  '⚠ $f',
                                  style: AppTypography.caption.copyWith(
                                    color: c.error,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      if (edited)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            editedLabel,
                            style: AppTypography.caption.copyWith(
                              color: c.primaryText,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined, size: 20, color: c.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
