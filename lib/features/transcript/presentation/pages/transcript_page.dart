import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/features/transcript/presentation/cubit/transcript_cubit.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

class TranscriptPage extends StatelessWidget {
  const TranscriptPage({required this.videoId, super.key});
  final String videoId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = newTranscriptCubit(videoId);
      unawaited(cubit.load());
      return cubit;
    },
    child: TranscriptView(videoId: videoId),
  );
}

class TranscriptView extends StatelessWidget {
  const TranscriptView({required this.videoId, super.key});
  final String videoId;

  static String _stamp(Duration d) {
    String p(int n) => n.toString().padLeft(2, '0');
    return d.inHours > 0
        ? '${d.inHours}:${p(d.inMinutes % 60)}:${p(d.inSeconds % 60)}'
        : '${p(d.inMinutes)}:${p(d.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return BlocBuilder<TranscriptCubit, TranscriptState>(
      builder: (context, s) {
        final cubit = context.read<TranscriptCubit>();
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.transcriptTitle),
            actions: [
              IconButton(
                tooltip: l10n.copyAll,
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: cubit.text(includeOriginal: false)),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.copied)),
                    );
                  }
                },
                icon: const Icon(Icons.copy_all_rounded),
              ),
              IconButton(
                tooltip: l10n.shareText,
                onPressed: () => unawaited(cubit.share(includeOriginal: false)),
                icon: const Icon(Icons.ios_share_rounded),
              ),
            ],
          ),
          body: s.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.screen),
                  itemCount: s.cues.length,
                  itemBuilder: (context, i) {
                    final cue = s.cues[i];
                    return InkWell(
                      onTap: () => unawaited(
                        context.push(
                          '/player/$videoId?t=${cue.start.inMilliseconds}',
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                _stamp(cue.start),
                                style: AppTypography.timecode.copyWith(
                                  fontSize: 12,
                                  color: c.muted,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cue.text,
                                    style: AppTypography.body.copyWith(
                                      fontSize: 17,
                                      height: 1.7,
                                    ),
                                  ),
                                  if (cue.original != null)
                                    Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Text(
                                        cue.original!,
                                        style: AppTypography.caption.copyWith(
                                          color: c.muted,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
