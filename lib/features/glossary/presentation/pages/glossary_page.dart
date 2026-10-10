import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/core/design_system/components/empty_state.dart';
import 'package:tarjuman/core/design_system/tokens/app_radius.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/features/glossary/presentation/cubit/glossary_cubit.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

class GlossaryPage extends StatelessWidget {
  const GlossaryPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<GlossaryCubit>(),
    child: const GlossaryView(),
  );
}

class GlossaryView extends StatelessWidget {
  const GlossaryView({super.key});

  Future<void> _add(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<GlossaryCubit>();
    final term = TextEditingController();
    final arabic = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addTerm),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: term,
              autofocus: true,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(hintText: l10n.sourceTerm),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: arabic,
              decoration: InputDecoration(hintText: l10n.arabicTerm),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (ok ?? false) await cubit.add(term.text, arabic.text);
    term.dispose();
    arabic.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.glossaryTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => unawaited(_add(context)),
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<GlossaryCubit, GlossaryState>(
        builder: (context, s) {
          if (s.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (s.entries.isEmpty) {
            return EmptyState(
              icon: Icons.translate_rounded,
              title: l10n.glossaryEmpty,
              body: l10n.glossaryHint,
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  l10n.glossaryHint,
                  style: AppTypography.caption.copyWith(color: c.muted),
                ),
              ),
              for (final e in s.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: AppRadius.mdAll,
                      border: Border.all(color: c.line),
                    ),
                    child: ListTile(
                      title: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(e.term),
                      ),
                      subtitle: Text(
                        e.arabic,
                        style: TextStyle(color: c.primaryText),
                      ),
                      trailing: IconButton(
                        onPressed: () => unawaited(
                          context.read<GlossaryCubit>().remove(e.id),
                        ),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
