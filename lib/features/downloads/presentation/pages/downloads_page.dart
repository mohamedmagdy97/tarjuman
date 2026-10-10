import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/core/design_system/components/app_progress_bar.dart';
import 'package:tarjuman/core/design_system/components/empty_state.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/core/error/failure_message.dart';
import 'package:tarjuman/features/downloads/presentation/cubit/downloads_cubit.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider.value(
      value: sl<DownloadsCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.downloadsTitle),
          actions: [
            Builder(
              builder: (context) => TextButton(
                onPressed: context.read<DownloadsCubit>().clearFinished,
                child: Text(l10n.downloadClearDone),
              ),
            ),
          ],
        ),
        body: BlocBuilder<DownloadsCubit, DownloadsState>(
          builder: (context, s) => s.tasks.isEmpty
              ? EmptyState(
                  icon: Icons.download_rounded,
                  title: l10n.downloadsEmpty,
                  body: l10n.browserStart,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.screen),
                  itemCount: s.tasks.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) => DownloadTile(task: s.tasks[i]),
                ),
        ),
      ),
    );
  }
}

class DownloadTile extends StatelessWidget {
  const DownloadTile({required this.task, super.key});
  final DownloadTask task;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final cubit = context.read<DownloadsCubit>();
    final failure = task.failure;
    final (String status, Widget? action) = switch (task.status) {
      DownloadStatus.queued => (l10n.downloadWaiting, null),
      DownloadStatus.running => ('', null),
      DownloadStatus.done => (
        l10n.downloadDone,
        TextButton(
          onPressed: () => unawaited(context.push('/setup/${task.videoId}')),
          child: Text(l10n.downloadOpen),
        ),
      ),
      DownloadStatus.failed => (
        failure == null ? '' : failureMessage(failure, l10n),
        TextButton(
          onPressed: () => cubit.retry(task.id),
          child: Text(l10n.downloadRetry),
        ),
      ),
    };
    final detail = failure?.message;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.displayTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body,
                  ),
                ),
                ?action,
                IconButton(
                  tooltip: l10n.cancel,
                  onPressed: () => task.status == DownloadStatus.running
                      ? cubit.cancel(task.id)
                      : cubit.remove(task.id),
                  icon: Icon(Icons.close_rounded, color: c.muted),
                ),
              ],
            ),
            if (task.status == DownloadStatus.running)
              AppProgressBar(value: task.progress),
            if (status.isNotEmpty)
              Text(
                status,
                style: AppTypography.caption.copyWith(color: c.muted),
              ),
            if (detail != null && detail.isNotEmpty)
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  l10n.downloadFailedReason(detail),
                  style: AppTypography.caption.copyWith(color: c.muted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
