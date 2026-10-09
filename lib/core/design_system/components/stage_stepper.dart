import 'package:flutter/material.dart';
import 'package:tarjuman/core/design_system/components/app_progress_bar.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';

enum StageState { done, active, pending }

class StageStep {
  const StageStep({required this.label, required this.state, this.progress});
  final String label;
  final StageState state;
  final double? progress;
}

class StageStepper extends StatelessWidget {
  const StageStepper({required this.steps, super.key});
  final List<StageStep> steps;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: Column(
                    children: [
                      _Dot(index: i + 1, state: steps[i].state),
                      if (i < steps.length - 1)
                        Expanded(
                          child: ColoredBox(
                            color: steps[i].state == StageState.done
                                ? c.signal
                                : c.line,
                            child: const SizedBox(width: 2),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[i].label,
                          style: AppTypography.label.copyWith(
                            fontWeight: FontWeight.w600,
                            color: steps[i].state == StageState.pending
                                ? c.muted
                                : c.text,
                          ),
                        ),
                        if (steps[i].state == StageState.active) ...[
                          const SizedBox(height: AppSpacing.sm),
                          AppProgressBar(value: steps[i].progress),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.index, required this.state});
  final int index;
  final StageState state;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg) = switch (state) {
      StageState.done => (c.signal, c.bg),
      StageState.active => (c.primary, c.onPrimary),
      StageState.pending => (c.raised, c.muted),
    };
    return DecoratedBox(
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: SizedBox.square(
        dimension: 28,
        child: Center(
          child: state == StageState.done
              ? Icon(Icons.check_rounded, size: 16, color: fg)
              : Text(
                  '$index',
                  style: AppTypography.caption.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
