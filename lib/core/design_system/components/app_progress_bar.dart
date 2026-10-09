import 'package:flutter/material.dart';
import 'package:tarjuman/core/design_system/tokens/app_radius.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';

/// [value] null = indeterminate. [done] switches to the success colour.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({this.value, this.done = false, super.key});

  final double? value;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipRRect(
      borderRadius: AppRadius.pill,
      child: LinearProgressIndicator(
        value: done ? 1 : value,
        minHeight: 6,
        backgroundColor: c.raised,
        color: done ? c.signal : c.primary,
      ),
    );
  }
}
