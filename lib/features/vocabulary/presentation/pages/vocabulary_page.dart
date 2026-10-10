import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/core/design_system/components/app_button.dart';
import 'package:tarjuman/core/design_system/components/empty_state.dart';
import 'package:tarjuman/core/design_system/tokens/app_radius.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/core/platform/speech/pronouncer.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/core/settings/settings_store.dart';
import 'package:tarjuman/features/vocabulary/domain/usecases/backup_vocabulary.dart';
import 'package:tarjuman/features/vocabulary/domain/usecases/export_vocabulary.dart';
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

  Future<void> _menu(BuildContext context, String action) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    switch (action) {
      case 'csv':
        await sl<ExportVocabulary>()();
      case 'backup':
        await sl<BackupVocabulary>()();
      case 'restore':
        final res = await sl<RestoreVocabulary>()();
        switch (res) {
          case Success(:final value) when value != null:
            messenger.showSnackBar(
              SnackBar(content: Text(l10n.wordsRestored(value))),
            );
          case Success():
            break;
          case Err():
            messenger.showSnackBar(
              SnackBar(content: Text(l10n.invalidBackup)),
            );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myVocabulary),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (v) => unawaited(_menu(context, v)),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'csv', child: Text(l10n.exportWords)),
              PopupMenuItem(value: 'backup', child: Text(l10n.backupWords)),
              PopupMenuItem(value: 'restore', child: Text(l10n.restoreWords)),
            ],
          ),
        ],
      ),
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
          final now = DateTime.now();
          final due = s.words.where((w) => w.isDue(now)).length;
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screen),
            itemCount: s.words.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppButton(
                    label: '${l10n.startReview} · ${l10n.dueToday(due)}',
                    icon: Icons.school_rounded,
                    expand: true,
                    onPressed: due == 0
                        ? null
                        : () => unawaited(context.push('/review')),
                  ),
                );
              }
              final w = s.words[i - 1];
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
                        tooltip: l10n.pronounce,
                        onPressed: () => unawaited(
                          sl<Pronouncer>().speak(
                            w.word,
                            languageCode: sl<SettingsStore>()
                                .readSourceLanguage(),
                          ),
                        ),
                        icon: Icon(Icons.volume_up_rounded, color: c.muted),
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
