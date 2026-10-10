import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/core/design_system/components/app_chip.dart';
import 'package:tarjuman/core/design_system/components/app_progress_bar.dart';
import 'package:tarjuman/core/design_system/components/empty_state.dart';
import 'package:tarjuman/core/design_system/components/status_pill.dart';
import 'package:tarjuman/core/design_system/components/video_card.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/core/error/failure_message.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/presentation/cubit/library_cubit.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<LibraryCubit>(),
    child: const LibraryView(),
  );
}

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  var _progressOpen = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<LibraryCubit, LibraryState>(
      listenWhen: (a, b) =>
          a.downloading != b.downloading ||
          (b.failure != null && a.failure != b.failure) ||
          (b.importedId != null && a.importedId != b.importedId),
      listener: (context, state) {
        final cubit = context.read<LibraryCubit>();
        if (state.downloading && !_progressOpen) {
          _progressOpen = true;
          unawaited(_showProgress(context, cubit));
        } else if (!state.downloading && _progressOpen) {
          _progressOpen = false;
          Navigator.of(context, rootNavigator: true).pop();
        }
        if (state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failureMessage(state.failure!, l10n))),
          );
          cubit.failureShown();
        }
        if (state.importedId != null) {
          final id = state.importedId!;
          cubit.importedHandled();
          unawaited(context.push('/setup/$id'));
        }
      },
      builder: (context, state) {
        final cubit = context.read<LibraryCubit>();
        return Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.libraryTitle,
              style: AppTypography.display.copyWith(fontSize: 26),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                tooltip: l10n.myVocabulary,
                onPressed: () => unawaited(context.push('/vocabulary')),
                icon: const Icon(Icons.menu_book_outlined),
              ),
              IconButton(
                tooltip: l10n.modelsTitle,
                onPressed: () => unawaited(context.push('/models')),
                icon: const Icon(Icons.download_for_offline_outlined),
              ),
              IconButton(
                tooltip: l10n.settings,
                onPressed: () => unawaited(context.push('/settings')),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          floatingActionButton: state.videos.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: state.importing
                      ? null
                      : () => unawaited(_showAddSheet(context, cubit)),
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addVideo),
                ),
          body: SafeArea(child: _body(context, state, cubit, l10n)),
        );
      },
    );
  }

  Future<void> _showAddSheet(BuildContext context, LibraryCubit cubit) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.video_library_outlined),
              title: Text(l10n.addFromGallery),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.video_file_outlined),
              title: Text(l10n.addFromDevice),
              onTap: () => Navigator.pop(ctx, 'file'),
            ),
            ListTile(
              leading: const Icon(Icons.link_rounded),
              title: Text(l10n.addFromLink),
              onTap: () => Navigator.pop(ctx, 'link'),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) return;
    switch (choice) {
      case 'gallery':
        await cubit.importVideo(gallery: true);
      case 'file':
        await cubit.importVideo();
      case 'link':
        await _askLink(context, cubit);
    }
  }

  Future<void> _askLink(BuildContext context, LibraryCubit cubit) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.linkTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.url,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(hintText: l10n.linkHint),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.linkNote,
              style: AppTypography.caption.copyWith(color: ctx.colors.muted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(l10n.linkDownload),
          ),
        ],
      ),
    );
    controller.dispose();
    if (url != null && url.trim().isNotEmpty) {
      unawaited(cubit.importFromUrl(url));
    }
  }

  Future<void> _showProgress(BuildContext context, LibraryCubit cubit) {
    final l10n = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: BlocBuilder<LibraryCubit, LibraryState>(
          builder: (context, s) => AlertDialog(
            title: Text(l10n.downloadingVideo),
            content: AppProgressBar(value: s.downloadProgress),
            actions: [
              TextButton(
                onPressed: cubit.cancelDownload,
                child: Text(l10n.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    LibraryState state,
    LibraryCubit cubit,
    AppLocalizations l10n,
  ) {
    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.videos.isEmpty) {
      return EmptyState(
        icon: Icons.movie_outlined,
        title: l10n.libraryEmptyTitle,
        body: l10n.libraryEmptyBody,
        actionLabel: l10n.addVideo,
        onAction: state.importing
            ? null
            : () => unawaited(_showAddSheet(context, cubit)),
      );
    }
    final filters = {
      LibraryFilter.all: l10n.filterAll,
      LibraryFilter.ready: l10n.filterReady,
      LibraryFilter.processing: l10n.filterProcessing,
      LibraryFilter.favorites: l10n.filterFavorites,
    };
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.screen,
        0,
        AppSpacing.screen,
        96,
      ),
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final e in filters.entries)
              AppChip(
                label: e.value,
                selected: state.filter == e.key,
                onTap: () => cubit.setFilter(e.key),
              ),
          ],
        ),
        for (final v in state.visible)
          VideoCard(
            title: v.title,
            pillLabel: _pillLabel(v, l10n),
            pillTone: _pillTone(v),
            caption: '',
            durationLabel: _duration(v.duration),
            isFavorite: v.isFavorite,
            favoriteTooltip: v.isFavorite
                ? l10n.removeFavorite
                : l10n.addFavorite,
            onFavorite: () => unawaited(cubit.toggleFavorite(v)),
            onTap: () => unawaited(
              context.push(
                v.status == VideoStatus.ready
                    ? '/player/${v.id}'
                    : '/setup/${v.id}',
              ),
            ),
            onLongPress: () => _confirmDelete(context, v, cubit, l10n),
          ),
      ],
    );
  }

  String? _duration(Duration? d) {
    if (d == null) return null;
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  String _pillLabel(Video v, AppLocalizations l10n) => switch (v.status) {
    VideoStatus.ready when v.origin == SubtitleOrigin.online =>
      l10n.statusOnline,
    VideoStatus.ready => l10n.statusReadyOffline,
    VideoStatus.processing => l10n.statusProcessing,
    VideoStatus.failed => l10n.statusFailed,
    VideoStatus.imported => l10n.videoImported,
  };

  PillTone _pillTone(Video v) => switch (v.status) {
    VideoStatus.ready when v.origin == SubtitleOrigin.online => PillTone.online,
    VideoStatus.ready => PillTone.ready,
    VideoStatus.processing => PillTone.processing,
    VideoStatus.failed => PillTone.failed,
    VideoStatus.imported => PillTone.processing,
  };

  Future<void> _confirmDelete(
    BuildContext context,
    Video v,
    LibraryCubit cubit,
    AppLocalizations l10n,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteVideoTitle),
        content: Text(l10n.deleteVideoBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.delete,
              style: TextStyle(color: context.colors.error),
            ),
          ),
        ],
      ),
    );
    if (ok ?? false) await cubit.delete(v.id);
  }
}
