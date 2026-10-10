import 'package:flutter/material.dart';
import 'package:tarjuman/core/design_system/components/app_button.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/features/browser/presentation/cubit/browser_cubit.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

/// Result of the sheet: media URLs to download, plus whether the page itself
/// (auto-detect, e.g. a YouTube link) was ticked.
typedef DetectedChoice = ({List<String> urls, bool page});

/// Lists the page itself and every detected video with checkboxes so one or
/// many can be queued at once.
class DetectedSheet extends StatefulWidget {
  const DetectedSheet({
    required this.detected,
    required this.pageTitle,
    super.key,
  });
  final List<DetectedVideo> detected;
  final String pageTitle;

  @override
  State<DetectedSheet> createState() => _DetectedSheetState();
}

class _DetectedSheetState extends State<DetectedSheet> {
  final _picked = <String>{};
  var _page = false;

  int get _count => _picked.length + (_page ? 1 : 0);

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
            Text(l10n.browserDetected, style: AppTypography.heading),
            const SizedBox(height: AppSpacing.sm),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  CheckboxListTile(
                    value: _page,
                    onChanged: (v) => setState(() => _page = v ?? false),
                    title: Text(l10n.browserDownloadPage),
                    subtitle: Text(
                      widget.pageTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.detected.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        l10n.browserNone,
                        style: AppTypography.caption.copyWith(color: c.muted),
                      ),
                    ),
                  for (final d in widget.detected)
                    CheckboxListTile(
                      value: _picked.contains(d.url),
                      onChanged: (v) => setState(
                        () => v ?? false
                            ? _picked.add(d.url)
                            : _picked.remove(d.url),
                      ),
                      title: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          d.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.browserDownloadSelected(_count),
              icon: Icons.download_rounded,
              expand: true,
              onPressed: _count == 0
                  ? null
                  : () => Navigator.pop<DetectedChoice>(context, (
                      urls: _picked.toList(),
                      page: _page,
                    )),
            ),
          ],
        ),
      ),
    );
  }
}
