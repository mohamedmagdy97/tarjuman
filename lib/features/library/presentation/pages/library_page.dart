import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/core/design_system/components/app_chip.dart';
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
    child: const _LibraryView(),
  );
}

class _LibraryView extends StatelessWidget {
  const _LibraryView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<LibraryCubit, LibraryState>(
      listenWhen: (a, b) => b.failure != null && a.failure != b.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failureMessage(state.failure!, l10n))),
        );
        context.read<LibraryCubit>().failureShown();
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
          ),
          floatingActionButton: state.videos.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: state.importing ? null : cubit.importVideo,
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
        onAction: state.importing ? null : cubit.importVideo,
      );
    }
    final filters = {
      LibraryFilter.all: l10n.filterAll,
      LibraryFilter.ready: l10n.filterReady,
      LibraryFilter.processing: l10n.filterProcessing,
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
            caption: v.hasSubtitles ? '' : l10n.videoImported,
            onTap: () => context.push('/player/${v.id}'),
            onLongPress: () => _confirmDelete(context, v, cubit, l10n),
          ),
      ],
    );
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
