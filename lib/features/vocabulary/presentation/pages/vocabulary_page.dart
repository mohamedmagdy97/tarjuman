import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/core/design_system/components/empty_state.dart';
import 'package:tarjuman/core/design_system/tokens/app_radius.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/features/vocabulary/presentation/cubit/vocabulary_cubit.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

class VocabularyPage extends StatelessWidget {
  const VocabularyPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<VocabularyCubit>(),
    child: const VocabularyView(),
  );
}

class VocabularyView extends StatelessWidget {
  const VocabularyView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myVocabulary)),
      body: BlocBuilder<VocabularyCubit, VocabularyState>(
        builder: (context, s) {
          if (s.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (s.words.isEmpty) {
            return EmptyState(
              icon: Icons.menu_book_outlined,
              title: l10n.vocabularyEmpty,
              body: l10n.vocabularyEmptyBody,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screen),
            itemCount: s.words.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) {
              final w = s.words[i];
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(color: c.line),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 4, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(w.word, style: AppTypography.heading),
                            ),
                            Text(
                              w.translation,
                              style: AppTypography.body.copyWith(
                                color: c.primaryText,
                              ),
                            ),
                            if (w.sentence != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    w.sentence!,
                                    style: AppTypography.caption.copyWith(
                                      color: c.muted,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.deleteWord,
                        onPressed: () =>
                            context.read<VocabularyCubit>().remove(w.id),
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: c.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
