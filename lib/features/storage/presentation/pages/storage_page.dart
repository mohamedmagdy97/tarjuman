import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/core/design_system/components/app_button.dart';
import 'package:tarjuman/core/design_system/tokens/app_radius.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/features/storage/presentation/cubit/storage_cubit.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

String formatBytes(int b) {
  if (b < 1024 * 1024) return '${(b / 1024).round()} KB';
  if (b < 1024 * 1024 * 1024) {
    return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(b / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

class StoragePage extends StatelessWidget {
  const StoragePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = sl<StorageCubit>();
      unawaited(cubit.load());
      return cubit;
    },
    child: const StorageView(),
  );
}

class StorageView extends StatelessWidget {
  const StorageView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.storageTitle)),
      body: BlocConsumer<StorageCubit, StorageState>(
        listenWhen: (a, b) => b.freed != null && a.freed != b.freed,
        listener: (context, s) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.freedSpace(formatBytes(s.freed!)))),
        ),
        builder: (context, s) {
          if (s.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final u = s.usage;
          Widget row(String label, int bytes) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(child: Text(label, style: AppTypography.body)),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    formatBytes(bytes),
                    style: AppTypography.timecode.copyWith(color: c.muted),
                  ),
                ),
              ],
            ),
          );
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: AppRadius.lgAll,
                  border: Border.all(color: c.line),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      row(l10n.storageVideos, u.videosBytes),
                      row(l10n.storageModels, u.modelsBytes),
                      row(l10n.storageTemp, u.tempBytes),
                      const Divider(),
                      row(l10n.storageTotal, u.totalBytes),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.clearTemp,
                icon: Icons.cleaning_services_rounded,
                kind: AppButtonKind.secondary,
                expand: true,
                onPressed: u.tempBytes == 0
                    ? null
                    : () => unawaited(context.read<StorageCubit>().clearTemp()),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.storageVideosList,
                style: AppTypography.caption.copyWith(
                  color: c.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              for (final v in u.videos)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      v.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  subtitle: Text(formatBytes(v.bytes)),
                  trailing: IconButton(
                    tooltip: l10n.delete,
                    onPressed: () => unawaited(
                      context.read<StorageCubit>().deleteVideo(v.id),
                    ),
                    icon: Icon(Icons.delete_outline_rounded, color: c.error),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
