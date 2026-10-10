import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/core/design_system/components/app_button.dart';
import 'package:tarjuman/core/design_system/components/empty_state.dart';
import 'package:tarjuman/core/design_system/tokens/app_radius.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/core/platform/speech/pronouncer.dart';
import 'package:tarjuman/core/settings/settings_store.dart';
import 'package:tarjuman/features/vocabulary/domain/services/spaced_repetition.dart';
import 'package:tarjuman/features/vocabulary/presentation/cubit/review_cubit.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = sl<ReviewCubit>();
      unawaited(cubit.load());
      return cubit;
    },
    child: const ReviewView(),
  );
}

class ReviewView extends StatelessWidget {
  const ReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewTitle)),
      body: BlocBuilder<ReviewCubit, ReviewState>(
        builder: (context, s) {
          if (s.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final card = s.current;
          if (card == null) {
            return EmptyState(
              icon: Icons.task_alt_rounded,
              title: l10n.reviewDone,
              body: l10n.reviewDoneBody(s.reviewed),
            );
          }
          final cubit = context.read<ReviewCubit>();
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: Column(
              children: [
                Text(
                  l10n.reviewRemaining(s.queue.length),
                  style: AppTypography.caption.copyWith(color: c.muted),
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: AppRadius.lgAll,
                      border: Border.all(color: c.line),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                card.word,
                                textAlign: TextAlign.center,
                                style: AppTypography.display,
                              ),
                            ),
                            IconButton(
                              tooltip: l10n.pronounce,
                              onPressed: () => unawaited(
                                sl<Pronouncer>().speak(
                                  card.word,
                                  languageCode: sl<SettingsStore>()
                                      .readSourceLanguage(),
                                ),
                              ),
                              icon: const Icon(Icons.volume_up_rounded),
                            ),
                            if (s.revealed) ...[
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                card.translation,
                                textAlign: TextAlign.center,
                                style: AppTypography.title.copyWith(
                                  color: c.primaryText,
                                ),
                              ),
                              if (card.sentence != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: AppSpacing.lg,
                                  ),
                                  child: Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Text(
                                      card.sentence!,
                                      textAlign: TextAlign.center,
                                      style: AppTypography.body.copyWith(
                                        color: c.muted,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (!s.revealed)
                  AppButton(
                    label: l10n.showAnswer,
                    expand: true,
                    onPressed: cubit.reveal,
                  )
                else
                  Row(
                    children: [
                      for (final g in ReviewGrade.values)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: AppButton(
                              label: switch (g) {
                                ReviewGrade.again => l10n.gradeAgain,
                                ReviewGrade.hard => l10n.gradeHard,
                                ReviewGrade.good => l10n.gradeGood,
                                ReviewGrade.easy => l10n.gradeEasy,
                              },
                              kind: g == ReviewGrade.good
                                  ? AppButtonKind.primary
                                  : AppButtonKind.secondary,
                              onPressed: () => unawaited(cubit.grade(g)),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
