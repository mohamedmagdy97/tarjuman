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
  double _tapX = 0;
  var _dragOnLeft = true;

  void _onDoubleTap(BuildContext context, PlayerCubit cubit) {
    final w = MediaQuery.sizeOf(context).width;
    if (_tapX < w * .4) {
      unawaited(cubit.seekBy(const Duration(seconds: -10)));
    } else if (_tapX > w * .6) {
      unawaited(cubit.seekBy(const Duration(seconds: 10)));
    } else {
      unawaited(cubit.togglePlay());
    }
  }

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
            onDoubleTapDown: (d) => _tapX = d.localPosition.dx,
            onDoubleTap: () => _onDoubleTap(context, cubit),
            onVerticalDragStart: (d) => _dragOnLeft =
                d.localPosition.dx < MediaQuery.sizeOf(context).width / 2,
            onVerticalDragUpdate: (d) {
              final h = MediaQuery.sizeOf(context).height;
              final delta = -d.delta.dy / (h * .55);
              unawaited(
                _dragOnLeft
                    ? cubit.adjustBrightness(delta)
                    : cubit.adjustVolume(delta),
              );
            },
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
                if (state.hud != null) _HudView(hud: state.hud!),
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
                              tooltip: AppLocalizations.of(context).loopAB,
                              onPressed: cubit.cycleLoop,
                              icon: Icon(
                                state.loopB != null
                                    ? Icons.repeat_on_rounded
                                    : Icons.repeat_rounded,
                              ),
                              color: state.loopA != null
                                  ? const Color(0xFFFFC93C)
                                  : Colors.white,
                            ),
                            if (state.snapshot.audioTracks.length > 1 ||
                                state.snapshot.subtitleTracks.isNotEmpty)
                              IconButton(
                                tooltip: AppLocalizations.of(context).tracks,
                                onPressed: () =>
                                    unawaited(_openTracks(context)),
                                icon: const Icon(Icons.audiotrack_rounded),
                                color: Colors.white,
                              ),
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

  Future<void> _openTracks(BuildContext context) async {
    final cubit = context.read<PlayerCubit>();
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: BlocBuilder<PlayerCubit, PlayerState>(
          buildWhen: (a, b) => a.snapshot != b.snapshot,
          builder: (context, s) {
            final snap = s.snapshot;
            Widget header(String t) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(t, style: AppTypography.heading),
            );
            return SafeArea(
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (snap.audioTracks.length > 1) ...[
                    header(l10n.audioTrack),
                    for (final t in snap.audioTracks)
                      ListTile(
                        title: Text(t.label),
                        trailing: snap.selectedAudio == t.id
                            ? const Icon(Icons.check_rounded)
                            : null,
                        onTap: () => unawaited(cubit.selectAudio(t.id)),
                      ),
                  ],
                  if (snap.subtitleTracks.isNotEmpty) ...[
                    header(l10n.embeddedSubtitles),
                    ListTile(
                      title: Text(l10n.subtitlesOff),
                      trailing: snap.selectedSubtitle == null
                          ? const Icon(Icons.check_rounded)
                          : null,
                      onTap: () => unawaited(cubit.selectSubtitleTrack(null)),
                    ),
                    for (final t in snap.subtitleTracks)
                      ListTile(
                        title: Text(t.label),
                        trailing: snap.selectedSubtitle == t.id
                            ? const Icon(Icons.check_rounded)
                            : null,
                        onTap: () => unawaited(cubit.selectSubtitleTrack(t.id)),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
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

class _HudView extends StatelessWidget {
  const _HudView({required this.hud});
  final PlayerHud hud;

  @override
  Widget build(BuildContext context) {
    final icon = switch (hud.kind) {
      HudKind.seekBack => Icons.replay_10_rounded,
      HudKind.seekForward => Icons.forward_10_rounded,
      HudKind.volume =>
        (hud.value ?? 0) == 0
            ? Icons.volume_off_rounded
            : Icons.volume_up_rounded,
      HudKind.brightness => Icons.brightness_6_rounded,
      HudKind.loop => Icons.repeat_rounded,
    };
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, -.55),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xCC05070B),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white),
                if (hud.value != null) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 110,
                    child: LinearProgressIndicator(
                      value: hud.value,
                      minHeight: 5,
                      color: const Color(0xFFFFC93C),
                      backgroundColor: Colors.white24,
                    ),
                  ),
                ],
                if (hud.label != null) ...[
                  const SizedBox(width: 10),
                  Text(
                    hud.label!,
                    style: AppTypography.label.copyWith(color: Colors.white),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
