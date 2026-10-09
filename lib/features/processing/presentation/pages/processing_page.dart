import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/core/design_system/components/app_button.dart';
import 'package:tarjuman/core/design_system/components/app_progress_bar.dart';
import 'package:tarjuman/core/design_system/components/stage_stepper.dart';
import 'package:tarjuman/core/design_system/components/status_pill.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/core/error/failure_message.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/presentation/cubit/processing_cubit.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

class ProcessingPage extends StatelessWidget {
  const ProcessingPage({required this.videoId, required this.kind, super.key});
  final String videoId;
  final EngineKind kind;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => newProcessingCubit(videoId, kind)..start(),
    child: ProcessingView(videoId: videoId),
  );
}

class ProcessingView extends StatelessWidget {
  const ProcessingView({required this.videoId, super.key});
  final String videoId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return BlocBuilder<ProcessingCubit, ProcessingState>(
      builder: (context, s) {
        final cubit = context.read<ProcessingCubit>();
        final pct = (s.fraction * 100).floor();
        return PopScope(
          canPop: s.status != ProcessingStatus.running,
          child: Scaffold(
            appBar: AppBar(
              title: Text(l10n.processingTitle),
              automaticallyImplyLeading: s.status != ProcessingStatus.running,
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screen),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: StatusPill(
                        label: cubit.kind == EngineKind.online
                            ? l10n.engineOnline
                            : l10n.engineOffline,
                        tone: cubit.kind == EngineKind.online
                            ? PillTone.online
                            : PillTone.ready,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      l10n.overallProgress,
                      style: AppTypography.caption.copyWith(color: c.muted),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        '$pct%',
                        style: AppTypography.timecode.copyWith(fontSize: 40),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppProgressBar(
                      value: s.fraction,
                      done: s.status == ProcessingStatus.done,
                    ),
                    if (s.remaining != null &&
                        s.status == ProcessingStatus.running)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          l10n.remainingTime(_fmt(s.remaining!)),
                          style: AppTypography.caption.copyWith(color: c.muted),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xxl),
                    StageStepper(steps: _steps(s, l10n)),
                    const Spacer(),
                    _footer(context, s, cubit, l10n),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<StageStep> _steps(ProcessingState s, AppLocalizations l10n) {
    final order = [
      (ProcessingStage.extractingAudio, l10n.stageExtract),
      (ProcessingStage.transcribing, l10n.stageTranscribe),
      (ProcessingStage.translating, l10n.stageTranslate),
    ];
    final activeIndex = order.indexWhere((e) => e.$1 == s.stage);
    final finished = s.status == ProcessingStatus.done;
    return [
      for (var i = 0; i < order.length; i++)
        StageStep(
          label: order[i].$2,
          state: finished || i < activeIndex
              ? StageState.done
              : i == activeIndex && s.status != ProcessingStatus.done
              ? StageState.active
              : StageState.pending,
        ),
    ];
  }

  Widget _footer(
    BuildContext context,
    ProcessingState s,
    ProcessingCubit cubit,
    AppLocalizations l10n,
  ) {
    final c = context.colors;
    switch (s.status) {
      case ProcessingStatus.running:
        return Column(
          children: [
            Row(
              children: [
                Icon(Icons.check_rounded, size: 16, color: c.signal),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.progressSaved,
                    style: AppTypography.caption.copyWith(color: c.muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.cancel,
              kind: AppButtonKind.secondary,
              expand: true,
              onPressed: cubit.cancel,
            ),
          ],
        );
      case ProcessingStatus.done:
        return AppButton(
          label: l10n.watchNow,
          icon: Icons.play_arrow_rounded,
          expand: true,
          onPressed: () => context.pushReplacement('/player/$videoId'),
        );
      case ProcessingStatus.failed:
      case ProcessingStatus.cancelled:
        final failed = s.status == ProcessingStatus.failed;
        return Column(
          children: [
            Text(
              failed
                  ? '${l10n.processingFailed}\n${failureMessage(s.failure!, l10n)}'
                  : l10n.processingCancelled,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: failed ? c.error : c.muted,
              ),
            ),
            if (failed && (s.failure!.message ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: ExpansionTile(
                  title: Text(
                    l10n.technicalDetails,
                    style: AppTypography.caption.copyWith(color: c.muted),
                  ),
                  tilePadding: EdgeInsets.zero,
                  children: [
                    SelectableText(
                      '${s.failure.runtimeType}: ${s.failure!.message}',
                      textDirection: TextDirection.ltr,
                      style: AppTypography.caption.copyWith(color: c.muted),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.resume,
              expand: true,
              onPressed: cubit.start,
            ),
          ],
        );
    }
  }

  String _fmt(Duration d) => d.inMinutes >= 1
      ? '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}'
      : '${d.inSeconds}s';
}
