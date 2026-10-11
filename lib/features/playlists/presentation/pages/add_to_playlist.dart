import 'package:flutter/material.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/features/playlists/domain/playlist_repository.dart';
import 'package:tarjuman/features/playlists/presentation/pages/playlists_page.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

/// Lets the user pick an existing playlist (or create one) and adds [videoIds].
Future<void> addToPlaylistDialog(
  BuildContext context,
  List<String> videoIds,
) async {
  final l10n = AppLocalizations.of(context);
  final repo = sl<PlaylistRepository>();
  final messenger = ScaffoldMessenger.of(context);
  final playlists = await repo.watchAll().first;
  if (!context.mounted) return;
  const create = '__new__';
  final choice = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.add_rounded),
            title: Text(l10n.newPlaylist),
            onTap: () => Navigator.pop(ctx, create),
          ),
          for (final p in playlists)
            ListTile(
              leading: const Icon(Icons.playlist_play_rounded),
              title: Text(p.name),
              onTap: () => Navigator.pop(ctx, p.id),
            ),
        ],
      ),
    ),
  );
  if (choice == null || !context.mounted) return;
  var id = choice;
  if (choice == create) {
    final name = await askName(context);
    if (name == null) return;
    id = (await repo.create(name)).id;
  }
  await repo.addVideos(id, videoIds);
  messenger.showSnackBar(SnackBar(content: Text(l10n.addedToPlaylist)));
}
