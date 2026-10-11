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
import 'package:tarjuman/core/design_system/tokens/app_radius.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/core/error/failure_message.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/presentation/cubit/library_cubit.dart';
import 'package:tarjuman/features/library/presentation/export_actions.dart';
import 'package:tarjuman/features/playlists/presentation/pages/add_to_playlist.dart';
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
  var _searching = false;
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toggleSearch(LibraryCubit cubit) {
    setState(() => _searching = !_searching);
    if (!_searching) {
      _search.clear();
      unawaited(cubit.setQuery(''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<LibraryCubit, LibraryState>(
      listenWhen: (a, b) =>
          (b.failure != null && a.failure != b.failure) ||
          (b.importedId != null && a.importedId != b.importedId),
      listener: (context, state) {
        final cubit = context.read<LibraryCubit>();
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
            title: _searching
                ? TextField(
                    controller: _search,
                    autofocus: true,
                    onChanged: (q) => unawaited(cubit.setQuery(q)),
                    decoration: InputDecoration(hintText: l10n.searchLibrary),
                  )
                : Text(
                    l10n.libraryTitle,
                    style: AppTypography.display.copyWith(fontSize: 26),
                  ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                tooltip: l10n.searchLibrary,
                onPressed: () => _toggleSearch(cubit),
                icon: Icon(
                  _searching ? Icons.close_rounded : Icons.search_rounded,
                ),
              ),
              if (!_searching) ...[
                IconButton(
                  tooltip: l10n.playlistsTitle,
                  onPressed: () => unawaited(context.push('/playlists')),
                  icon: const Icon(Icons.playlist_play_rounded),
                ),
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
        unawaited(context.push('/browser'));
    }
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
    final searching = state.query.trim().isNotEmpty;
    final continuing = state.continueWatching;
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.screen,
        0,
        AppSpacing.screen,
        96,
      ),
      children: [
        if (!searching &&
            continuing.isNotEmpty &&
            state.filter == LibraryFilter.all) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              l10n.continueWatching,
              style: AppTypography.heading,
            ),
          ),
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: continuing.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, i) => _ContinueCard(video: continuing[i]),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
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
            onLongPress: () => unawaited(_showActions(context, v, cubit, l10n)),
          ),
        if (searching && state.hits.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Text(l10n.inSubtitles, style: AppTypography.heading),
          ),
          for (final h in state.hits)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(h.text, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  h.videoTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              onTap: () => unawaited(
                context.push(
                  '/player/${h.videoId}?t=${h.start.inMilliseconds}',
                ),
              ),
            ),
        ],
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

  Future<void> _showActions(
    BuildContext context,
    Video v,
    LibraryCubit cubit,
    AppLocalizations l10n,
  ) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.save_alt_rounded),
              title: Text(l10n.saveToDevice),
              onTap: () => Navigator.pop(ctx, 'save'),
            ),
            ListTile(
              leading: const Icon(Icons.ios_share_rounded),
              title: Text(l10n.shareFile),
              onTap: () => Navigator.pop(ctx, 'share'),
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add_rounded),
              title: Text(l10n.addToPlaylist),
              onTap: () => Navigator.pop(ctx, 'playlist'),
            ),
            ListTile(
              leading: const Icon(Icons.audiotrack_rounded),
              title: Text(l10n.extractAudio),
              onTap: () => Navigator.pop(ctx, 'audio'),
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline_rounded,
                color: ctx.colors.error,
              ),
              title: Text(l10n.delete),
              onTap: () => Navigator.pop(ctx, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) return;
    switch (choice) {
      case 'save':
        await runVideoFileAction(context, v.id, VideoFileAction.saveToDevice);
      case 'share':
        await runVideoFileAction(context, v.id, VideoFileAction.share);
      case 'playlist':
        await addToPlaylistDialog(context, [v.id]);
      case 'audio':
        await runVideoFileAction(context, v.id, VideoFileAction.extractAudio);
      case 'delete':
        await _confirmDelete(context, v, cubit, l10n);
    }
  }

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

/// Poster card with a progress bar for "continue watching".
class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.video});
  final Video video;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final total = video.duration?.inMilliseconds ?? 0;
    final progress = total == 0
        ? null
        : (video.lastPosition.inMilliseconds / total).clamp(0.0, 1.0);
    return InkWell(
      borderRadius: AppRadius.mdAll,
      onTap: () => unawaited(
        context.push(
          video.status == VideoStatus.ready
              ? '/player/${video.id}'
              : '/setup/${video.id}',
        ),
      ),
      child: SizedBox(
        width: 190,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: c.line),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.play_circle_fill_rounded,
                  color: c.primary,
                  size: 30,
                ),
                const Spacer(),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppProgressBar(value: progress),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
