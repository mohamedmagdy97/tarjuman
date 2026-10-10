import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/core/design_system/components/app_progress_bar.dart';
import 'package:tarjuman/core/design_system/components/status_pill.dart';
import 'package:tarjuman/core/design_system/tokens/app_radius.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/features/model_manager/domain/entities/model_info.dart';
import 'package:tarjuman/features/model_manager/presentation/cubit/models_cubit.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

class ModelsPage extends StatelessWidget {
  const ModelsPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = sl<ModelsCubit>();
      unawaited(cubit.load());
      return cubit;
    },
    child: const ModelsView(),
  );
}

class ModelsView extends StatelessWidget {
  const ModelsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.modelsTitle)),
      body: BlocConsumer<ModelsCubit, ModelsState>(
        listenWhen: (a, b) => b.downloadFailed && !a.downloadFailed,
        listener: (context, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.modelsDownloadFailed)),
          );
          context.read<ModelsCubit>().failureShown();
        },
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          Widget section(String title, ModelKind kind) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.lg,
                  bottom: AppSpacing.sm,
                ),
                child: Text(
                  title,
                  style: AppTypography.caption.copyWith(
                    color: context.colors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              for (final m in state.models.where((m) => m.kind == kind))
                _ModelTile(model: m, state: state),
            ],
          );
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            children: [
              section(l10n.speechModels, ModelKind.speech),
              section(l10n.translationModels, ModelKind.translation),
            ],
          );
        },
      ),
    );
  }
}

class _ModelTile extends StatelessWidget {
  const _ModelTile({required this.model, required this.state});
  final ModelInfo model;
  final ModelsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final cubit = context.read<ModelsCubit>();
    final downloading = state.progress.containsKey(model.id);
    final p = state.progress[model.id];
    final mb = (model.sizeBytes / (1024 * 1024)).round();

    final Widget action;
    if (downloading) {
      action = p == null
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '${(p * 100).round()}%',
                style: AppTypography.timecode.copyWith(color: c.primaryText),
              ),
            );
    } else if (model.installed) {
      action = IconButton(
        tooltip: l10n.delete,
        onPressed: () => cubit.remove(model.id),
        icon: Icon(Icons.check_circle_rounded, color: c.signal),
      );
    } else {
      action = IconButton.filled(
        tooltip: l10n.download,
        style: IconButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
        ),
        onPressed: () => cubit.download(model.id),
        icon: const Icon(Icons.download_rounded),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: c.line),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            model.name,
                            style: AppTypography.label.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (model.recommended) ...[
                          const SizedBox(width: AppSpacing.sm),
                          StatusPill(
                            label: l10n.recommendedForDevice,
                            tone: PillTone.ready,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      downloading ? l10n.downloading : l10n.sizeMb(mb),
                      style: AppTypography.caption.copyWith(color: c.muted),
                    ),
                    if (downloading) ...[
                      const SizedBox(height: AppSpacing.sm),
                      AppProgressBar(value: p),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              action,
            ],
          ),
        ),
      ),
    );
  }
}
