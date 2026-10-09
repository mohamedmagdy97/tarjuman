import 'package:flutter/material.dart';
import 'package:tarjuman/core/design_system/tokens/app_radius.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';

class AppSegmented<T> extends StatelessWidget {
  const AppSegmented({
    required this.options,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final Map<T, String> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(color: c.raised, borderRadius: AppRadius.mdAll),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            for (final e in options.entries)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: e.key == value,
                  child: InkWell(
                    borderRadius: AppRadius.smAll,
                    onTap: () => onChanged(e.key),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: e.key == value ? c.primary : null,
                          borderRadius: AppRadius.smAll,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 8,
                            ),
                            child: Text(
                              e.value,
                              textAlign: TextAlign.center,
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: e.key == value ? c.onPrimary : c.muted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
