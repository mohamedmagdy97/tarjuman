import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/core/design_system/components/empty_state.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/features/playlists/presentation/cubit/playlists_cubit.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => PlaylistsCubit(sl()),
    child: const _PlaylistsView(),
  );
}

Future<String?> askName(BuildContext context, {String initial = ''}) async {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: initial);
  final name = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.playlistName),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, controller.text),
          child: Text(l10n.save),
        ),
      ],
    ),
  );
  controller.dispose();
  return name?.trim().isEmpty ?? true ? null : name!.trim();
}

class _PlaylistsView extends StatelessWidget {
  const _PlaylistsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final cubit = context.read<PlaylistsCubit>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.playlistsTitle)),
      floatingActionButton: FloatingActionButton(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        onPressed: () async {
          final name = await askName(context);
          if (name != null) await cubit.create(name);
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<PlaylistsCubit, PlaylistsState>(
        builder: (context, s) {
          if (s.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (s.playlists.isEmpty) {
            return EmptyState(
              icon: Icons.playlist_play_rounded,
              title: l10n.playlistsEmpty,
              body: l10n.playlistsEmptyBody,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screen),
            itemCount: s.playlists.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) {
              final p = s.playlists[i];
              return ListTile(
                tileColor: c.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                ),
                leading: const Icon(Icons.playlist_play_rounded),
                title: Text(p.name),
                subtitle: Text(l10n.playlistCount(p.count)),
                onTap: () => unawaited(context.push('/playlist/${p.id}')),
                trailing: IconButton(
                  tooltip: l10n.delete,
                  icon: Icon(Icons.delete_outline_rounded, color: c.muted),
                  onPressed: () => unawaited(cubit.delete(p.id)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
