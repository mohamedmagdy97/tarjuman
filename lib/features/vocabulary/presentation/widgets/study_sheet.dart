import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/core/design_system/components/app_button.dart';
import 'package:tarjuman/core/design_system/tokens/app_radius.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/features/player/presentation/cubit/player_cubit.dart';
import 'package:tarjuman/features/vocabulary/presentation/cubit/study_cubit.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

/// Sentence-by-sentence study: navigate cues, loop one, tap words to translate
/// and save them.
class StudySheet extends StatelessWidget {
  const StudySheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final player = context.read<PlayerCubit>();
    return SafeArea(
      child: BlocBuilder<PlayerCubit, PlayerState>(
        buildWhen: (a, b) =>
            a.activeText != b.activeText ||
            a.activeOriginal != b.activeOriginal ||
            a.loopB != b.loopB,
        builder: (context, p) {
          final english = p.activeOriginal ?? '';
          final looping = p.loopA != null && p.loopB != null;
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(l10n.studyMode, style: AppTypography.heading),
                    const Spacer(),
                    IconButton(
                      tooltip: l10n.previousSentence,
                      onPressed: () => unawaited(player.previousCue()),
                      icon: const Icon(Icons.skip_previous_rounded),
                    ),
                    IconButton(
                      tooltip: l10n.repeatSentence,
                      onPressed: () => unawaited(player.repeatCurrentCue()),
                      icon: Icon(
                        looping
                            ? Icons.repeat_on_rounded
                            : Icons.repeat_rounded,
                        color: looping ? c.primaryText : null,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.nextSentence,
                      onPressed: () => unawaited(player.nextCue()),
                      icon: const Icon(Icons.skip_next_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (english.isEmpty)
                  Text(
                    l10n.tapAWord,
                    style: AppTypography.body.copyWith(color: c.muted),
                  )
                else
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final w in english.split(RegExp(r'\s+')))
                          ActionChip(
                            label: Text(w),
                            onPressed: () => unawaited(
                              context.read<StudyCubit>().selectWord(
                                w,
                                sentence: english,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                if (p.activeText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: Text(
                      p.activeText!,
                      style: AppTypography.body.copyWith(color: c.muted),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                const _WordCard(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  const _WordCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return BlocBuilder<StudyCubit, StudyState>(
      builder: (context, s) {
        if (s.word == null) return const SizedBox.shrink();
        return DecoratedBox(
          decoration: BoxDecoration(
            color: c.raised,
            borderRadius: AppRadius.mdAll,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          s.word!,
                          style: AppTypography.heading,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.loading
                            ? l10n.translatingWord
                            : s.failure != null
                            ? l10n.wordNeedsModels
                            : s.translation ?? '',
                        style: AppTypography.body.copyWith(
                          color: s.failure != null ? c.error : c.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (s.translation != null)
                  AppButton(
                    label: s.saved ? l10n.wordSaved : l10n.saveWord,
                    icon: s.saved
                        ? Icons.check_rounded
                        : Icons.star_outline_rounded,
                    kind: s.saved
                        ? AppButtonKind.secondary
                        : AppButtonKind.primary,
                    onPressed: s.saved
                        ? null
                        : () => unawaited(context.read<StudyCubit>().save()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
