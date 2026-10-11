import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/core/design_system/components/app_button.dart';
import 'package:tarjuman/core/design_system/components/empty_state.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/usecases/watch_library.dart';
import 'package:tarjuman/features/playlists/presentation/cubit/playlists_cubit.dart';
import 'package:tarjuman/features/playlists/presentation/pages/playlists_page.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({required this.playlistId, super.key});
  final String playlistId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => PlaylistCubit(sl(), playlistId),
    child: _PlaylistView(playlistId: playlistId),
  );
}

class _PlaylistView extends StatelessWidget {
  const _PlaylistView({required this.playlistId});
  final String playlistId;

  Future<void> _pickVideos(BuildContext context, PlaylistCubit cubit) async {
    final l10n = AppLocalizations.of(context);
    final inList = cubit.state.videos.map((v) => v.id).toSet();
    final all = await sl<WatchLibrary>()().first;
    if (!context.mounted) return;
    final candidates = [
      for (final v in all)
        if (!inList.contains(v.id)) v,
    ]..sort((a, b) => _natural(a.title, b.title));
    final picked = <String>{};
    final ids = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: candidates.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Text(l10n.noVideosToAdd),
                        )
                      : ListView(
                          shrinkWrap: true,
                          children: [
                            for (final v in candidates)
                              CheckboxListTile(
                                value: picked.contains(v.id),
                                title: Text(
                                  v.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onChanged: (on) => setState(
                                  () => on ?? false
                                      ? picked.add(v.id)
                                      : picked.remove(v.id),
                                ),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: l10n.addToPlaylistCount(picked.length),
                  expand: true,
                  onPressed: picked.isEmpty
                      ? null
                      : () => Navigator.pop(ctx, [
                          for (final v in candidates)
                            if (picked.contains(v.id)) v.id,
                        ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (ids != null) await cubit.addVideos(ids);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final cubit = context.read<PlaylistCubit>();
    return BlocBuilder<PlaylistCubit, PlaylistState>(
      builder: (context, s) {
        final target = s.resumeTarget;
        return Scaffold(
          appBar: AppBar(
            title: Text(s.playlist?.name ?? ''),
            actions: [
              IconButton(
                tooltip: l10n.playlistName,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  final name = await askName(
                    context,
                    initial: s.playlist?.name ?? '',
                  );
                  if (name != null) await cubit.rename(name);
                },
              ),
              IconButton(
                tooltip: l10n.addVideo,
                icon: const Icon(Icons.playlist_add_rounded),
                onPressed: () => unawaited(_pickVideos(context, cubit)),
              ),
            ],
          ),
          body: s.videos.isEmpty
              ? EmptyState(
                  icon: Icons.playlist_add_rounded,
                  title: l10n.playlistEmpty,
                  body: l10n.playlistEmptyBody,
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.screen),
                  children: [
                    if (target != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: AppButton(
                          label: s.playlist?.lastVideoId == null
                              ? l10n.playAll
                              : l10n.continueWatching,
                          icon: Icons.play_arrow_rounded,
                          expand: true,
                          onPressed: () => unawaited(
                            context.push(
                              '/player/${target.id}?playlist=$playlistId',
                            ),
                          ),
                        ),
                      ),
                    for (var i = 0; i < s.videos.length; i++)
                      ListTile(
                        tileColor: s.videos[i].id == s.playlist?.lastVideoId
                            ? c.raised
                            : null,
                        leading: CircleAvatar(child: Text('${i + 1}')),
                        title: Text(
                          s.videos[i].title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: _progress(s.videos[i], l10n),
                        onTap: () => unawaited(
                          context.push(
                            '/player/${s.videos[i].id}?playlist=$playlistId',
                          ),
                        ),
                        trailing: IconButton(
                          tooltip: l10n.removeFromPlaylist,
                          icon: Icon(Icons.close_rounded, color: c.muted),
                          onPressed: () =>
                              unawaited(cubit.remove(s.videos[i].id)),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }

  Widget? _progress(Video v, AppLocalizations l10n) {
    final d = v.duration;
    if (d == null || d == Duration.zero || v.lastPosition.inSeconds < 10) {
      return null;
    }
    final pct = (v.lastPosition.inMilliseconds * 100 / d.inMilliseconds)
        .clamp(0, 100)
        .round();
    return Text('$pct%');
  }

  /// "Episode 2" sorts before "Episode 10".
  static int _natural(String a, String b) {
    final re = RegExp(r'\d+|\D+');
    final pa = re.allMatches(a.toLowerCase()).map((m) => m.group(0)!).toList();
    final pb = re.allMatches(b.toLowerCase()).map((m) => m.group(0)!).toList();
    for (var i = 0; i < pa.length && i < pb.length; i++) {
      final na = int.tryParse(pa[i]);
      final nb = int.tryParse(pb[i]);
      final r = na != null && nb != null
          ? na.compareTo(nb)
          : pa[i].compareTo(pb[i]);
      if (r != 0) return r;
    }
    return pa.length.compareTo(pb.length);
  }
}
