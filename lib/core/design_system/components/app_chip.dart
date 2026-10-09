import 'package:flutter/material.dart';
import 'package:tarjuman/core/design_system/tokens/app_radius.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: selected ? c.primary : c.raised,
                borderRadius: AppRadius.smAll,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                child: Text(
                  label,
                  style: AppTypography.label.copyWith(
                    fontSize: 13,
                    color: selected ? c.onPrimary : c.muted,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
