import 'package:flutter/material.dart';
import 'package:tarjuman/core/design_system/tokens/app_radius.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';

enum AppButtonKind { primary, secondary, ghost, destructive }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.kind = AppButtonKind.primary,
    this.icon,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonKind kind;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg, border) = switch (kind) {
      AppButtonKind.primary => (c.primary, c.onPrimary, null),
      AppButtonKind.secondary => (c.raised, c.text, null),
      AppButtonKind.ghost => (Colors.transparent, c.primaryText, c.line),
      AppButtonKind.destructive => (
        Colors.transparent,
        c.error,
        c.error.withValues(alpha: .5),
      ),
    };

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 52,
        minWidth: expand ? double.infinity : 0,
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withValues(alpha: .4),
          disabledForegroundColor: fg.withValues(alpha: .4),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.xl,
          ),
          textStyle: AppTypography.label.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
            side: border == null ? BorderSide.none : BorderSide(color: border),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 22),
              const SizedBox(width: AppSpacing.sm),
            ],
            Flexible(child: Text(label)),
          ],
        ),
      ),
    );
  }
}
