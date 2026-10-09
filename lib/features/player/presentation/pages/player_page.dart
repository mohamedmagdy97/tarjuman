import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/core/design_system/components/app_button.dart';
import 'package:tarjuman/core/design_system/components/subtitle_view.dart';
import 'package:tarjuman/core/design_system/tokens/app_motion.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/error/failure_message.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_style.dart';
import 'package:tarjuman/features/player/presentation/cubit/player_cubit.dart';
import 'package:tarjuman/features/player/presentation/widgets/subtitle_style_sheet.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({
    required this.videoId,
    this.liveKind,
    this.startAtMs,
    super.key,
  });
  final String videoId;
  final EngineKind? liveKind;
  final int? startAtMs;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = newPlayerCubit(
        videoId,
        liveKind: liveKind,
        startAt: startAtMs == null ? null : Duration(milliseconds: startAtMs!),
      );
      unawaited(cubit.start());
      return cubit;
    },
    child: const PlayerView(),
  );
}

class PlayerView extends StatefulWidget {
  const PlayerView({super.key});

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  @override
  void initState() {
    super.initState();
    unawaited(
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
    );
  }

  @override
  void dispose() {
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<PlayerCubit, PlayerState>(
      listenWhen: (a, b) => b.failure != null && a.failure != b.failure,
      listener: (context, s) {
        if (s.status != PlayerStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failureMessage(s.failure!, l10n))),
          );
          context.read<PlayerCubit>().failureShown();
        }
      },
      builder: (context, state) {
        final cubit = context.read<PlayerCubit>();
        if (state.status == PlayerStatus.error) {
          return _Error(onBack: () => context.pop());
        }
        return Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: cubit.toggleControls,
            child: Stack(
              fit: StackFit.expand,
              children: [
                cubit.engine.buildSurface(),
                if (state.timeline.isEmpty &&
                    state.status == PlayerStatus.ready)
                  _NoSubtitles(
                    onAttach: cubit.attachSubtitles,
                    onTranslate: () =>
                        unawaited(context.push('/setup/${state.video?.id}')),
                  ),
                AnimatedOpacity(
                  opacity: state.controlsVisible ? 1 : 0,
                  duration: AppMotion.micro,
                  child: IgnorePointer(
                    ignoring: !state.controlsVisible,
                    child: _Controls(state: state),
                  ),
                ),
                // Above the controls scrim so subtitles are never dimmed.
                _SubtitleLayer(state: state),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SubtitleLayer extends StatelessWidget {
  const _SubtitleLayer({required this.state});
  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final top = state.style.position == SubtitlePosition.top;
    // Lift above the transport bar while controls are visible.
    final bottom = state.controlsVisible ? 128.0 : AppSpacing.xl;
    return Positioned.fill(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xl,
            top ? 72 : 0,
            AppSpacing.xl,
            top ? 0 : bottom,
          ),
          child: Align(
            alignment: top ? Alignment.topCenter : Alignment.bottomCenter,
            child: IgnorePointer(
              child: SubtitleView(
                text: state.activeText,
                original: state.activeOriginal,
                style: state.style,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.state});
  final PlayerState state;

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlayerCubit>();
    final snap = state.snapshot;
    final total = snap.duration.inMilliseconds;
    final pos = snap.position.inMilliseconds.clamp(0, total == 0 ? 1 : total);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xCC05070B), Colors.transparent, Color(0xEB05070B)],
          stops: [0, .35, 1],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: Colors.white,
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                  ),
                  if (state.liveBusy)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: Row(
                        children: [
                          const SizedBox.square(
                            dimension: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppLocalizations.of(context).liveTranslating,
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Text(
                      state.video?.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.ltr,
                      style: AppTypography.label.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton.filled(
                iconSize: 40,
                onPressed: cubit.togglePlay,
                icon: Icon(
                  snap.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                ),
              ),
              const Spacer(),
              // Transport controls stay LTR, like every video player.
              Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(_fmt(snap.position), style: _tc),
                        Expanded(
                          child: Slider(
                            value: pos.toDouble(),
                            max: total == 0 ? 1 : total.toDouble(),
                            onChanged: total == 0
                                ? null
                                : (v) => cubit.seek(
                                    Duration(milliseconds: v.round()),
                                  ),
                          ),
                        ),
                        Text(_fmt(snap.duration), style: _tc),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PopupMenuButton<double>(
                          initialValue: snap.speed,
                          onSelected: cubit.setSpeed,
                          itemBuilder: (_) => [
                            for (final s in _speeds)
                              PopupMenuItem(value: s, child: Text('$s×')),
                          ],
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Text('${snap.speed}×', style: _tc),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: cubit.attachSubtitles,
                              icon: const Icon(Icons.closed_caption_outlined),
                              color: Colors.white,
                            ),
                            IconButton(
                              tooltip: AppLocalizations.of(
                                context,
                              ).editSubtitles,
                              onPressed: state.timeline.isEmpty
                                  ? null
                                  : () => unawaited(
                                      context.push(
                                        '/editor/${state.video?.id}',
                                      ),
                                    ),
                              icon: const Icon(Icons.edit_note_rounded),
                              color: Colors.white,
                            ),
                            IconButton(
                              onPressed: () => unawaited(_openStyle(context)),
                              icon: const Icon(Icons.tune_rounded),
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static final TextStyle _tc = AppTypography.timecode.copyWith(
    color: Colors.white,
  );

  static String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  Future<void> _openStyle(BuildContext context) async {
    final cubit = context.read<PlayerCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: BlocBuilder<PlayerCubit, PlayerState>(
          buildWhen: (a, b) => a.style != b.style,
          builder: (context, s) => SubtitleStyleSheet(
            style: s.style,
            onChanged: cubit.updateStyle,
          ),
        ),
      ),
    );
  }
}

class _NoSubtitles extends StatelessWidget {
  const _NoSubtitles({required this.onAttach, required this.onTranslate});
  final VoidCallback onAttach;
  final VoidCallback onTranslate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Align(
      alignment: const Alignment(0, .55),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.noSubtitlesBody,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.translateThisVideo,
              icon: Icons.translate_rounded,
              onPressed: onTranslate,
            ),
            TextButton(
              onPressed: onAttach,
              child: Text(l10n.orAddSubtitleFile),
            ),
          ],
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.playbackError, style: AppTypography.heading),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.cancel,
              kind: AppButtonKind.secondary,
              onPressed: onBack,
            ),
          ],
        ),
      ),
    );
  }
}
