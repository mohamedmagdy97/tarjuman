import 'package:flutter/material.dart';
import 'package:tarjuman/core/design_system/components/app_chip.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

/// Landing view before any page is opened: explanation + popular sites.
class BrowserStart extends StatelessWidget {
  const BrowserStart({required this.onOpen, super.key});
  final ValueChanged<String> onOpen;

  static const sites = {
    'YouTube': 'https://m.youtube.com',
    'Facebook': 'https://m.facebook.com',
    'Instagram': 'https://www.instagram.com',
    'TikTok': 'https://www.tiktok.com',
    'X': 'https://x.com',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.public_rounded, size: 64, color: context.colors.muted),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.browserStart,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: context.colors.muted),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: [
                for (final e in sites.entries)
                  AppChip(
                    label: e.key,
                    selected: false,
                    onTap: () => onOpen(e.value),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
