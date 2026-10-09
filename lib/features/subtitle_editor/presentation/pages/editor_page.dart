import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/core/design_system/components/app_button.dart';
import 'package:tarjuman/core/design_system/components/cue_tile.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';
import 'package:tarjuman/features/subtitle_editor/presentation/cubit/editor_cubit.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({required this.videoId, super.key});
  final String videoId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = newEditorCubit(videoId);
      unawaited(cubit.load());
      return cubit;
    },
    child: EditorView(videoId: videoId),
  );
}

class EditorView extends StatelessWidget {
  const EditorView({required this.videoId, super.key});
  final String videoId;

  static String timecode(Duration d) {
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(d.inHours)}:${p(d.inMinutes.remainder(60))}:'
        '${p(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<EditorCubit, EditorState>(
      builder: (context, s) {
        final cubit = context.read<EditorCubit>();
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.editSubtitles),
            actions: [
              PopupMenuButton<bool>(
                tooltip: l10n.exportSrt,
                icon: const Icon(Icons.ios_share_rounded),
                onSelected: (both) =>
                    unawaited(cubit.export(includeOriginal: both)),
                itemBuilder: (_) => [
                  PopupMenuItem(value: false, child: Text(l10n.exportSrt)),
                  PopupMenuItem(
                    value: true,
                    child: Text('${l10n.exportSrt} · ${l10n.exportBoth}'),
                  ),
                ],
              ),
            ],
          ),
          body: s.loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screen,
                        0,
                        AppSpacing.screen,
                        AppSpacing.md,
                      ),
                      child: TextField(
                        onChanged: cubit.search,
                        decoration: InputDecoration(
                          hintText: l10n.searchCues,
                          prefixIcon: const Icon(Icons.search_rounded),
                        ),
                      ),
                    ),
                    Expanded(
                      child: s.visible.isEmpty
                          ? Center(
                              child: Text(
                                l10n.noResults,
                                style: AppTypography.body.copyWith(
                                  color: context.colors.muted,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.screen,
                              ),
                              itemCount: s.visible.length,
                              itemBuilder: (context, i) {
                                final c = s.visible[i];
                                return CueTile(
                                  timecode: timecode(c.start),
                                  text: c.text,
                                  original: c.original,
                                  edited: c.status == CueStatus.edited,
                                  editedLabel: l10n.edited,
                                  onTap: () => unawaited(
                                    context.push(
                                      '/player/$videoId'
                                      '?t=${c.start.inMilliseconds}',
                                    ),
                                  ),
                                  onEdit: () =>
                                      unawaited(_edit(context, cubit, c)),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _edit(
    BuildContext context,
    EditorCubit cubit,
    SubtitleCue cue,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: cue.text);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.screen,
          AppSpacing.screen,
          MediaQuery.viewInsetsOf(ctx).bottom + AppSpacing.screen,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.editCueTitle, style: AppTypography.heading),
            if (cue.original != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  cue.original!,
                  textDirection: TextDirection.ltr,
                  style: AppTypography.caption.copyWith(
                    color: ctx.colors.muted,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            TextField(controller: controller, autofocus: true, maxLines: 3),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.saveEdit,
              expand: true,
              onPressed: () {
                unawaited(cubit.save(cue, controller.text));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }
}
