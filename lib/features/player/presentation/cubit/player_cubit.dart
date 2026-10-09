import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/core/design_system/tokens/app_motion.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/platform/media/player_engine.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/core/settings/settings_store.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_style.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_timeline.dart';
import 'package:tarjuman/features/player/domain/usecases/attach_subtitles.dart';
import 'package:tarjuman/features/player/domain/usecases/load_player_data.dart';

enum PlayerStatus { loading, ready, error }

class PlayerState extends Equatable {
  const PlayerState({
    this.status = PlayerStatus.loading,
    this.video,
    this.timeline = const SubtitleTimeline.empty(),
    this.snapshot = const PlaybackSnapshot(),
    this.style = const SubtitleStyle(),
    this.activeText,
    this.controlsVisible = true,
    this.failure,
  });

  final PlayerStatus status;
  final Video? video;
  final SubtitleTimeline timeline;
  final PlaybackSnapshot snapshot;
  final SubtitleStyle style;
  final String? activeText;
  final bool controlsVisible;
  final Failure? failure;

  PlayerState copyWith({
    PlayerStatus? status,
    Video? video,
    SubtitleTimeline? timeline,
    PlaybackSnapshot? snapshot,
    SubtitleStyle? style,
    String? activeText,
    bool clearActive = false,
    bool? controlsVisible,
    Failure? failure,
    bool clearFailure = false,
  }) => PlayerState(
    status: status ?? this.status,
    video: video ?? this.video,
    timeline: timeline ?? this.timeline,
    snapshot: snapshot ?? this.snapshot,
    style: style ?? this.style,
    activeText: clearActive ? null : activeText ?? this.activeText,
    controlsVisible: controlsVisible ?? this.controlsVisible,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [
    status,
    video,
    timeline.cues.length,
    snapshot,
    style,
    activeText,
    controlsVisible,
    failure,
  ];
}

class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit({
    required this.videoId,
    required this.engine,
    required LoadPlayerData load,
    required AttachSubtitles attach,
    required SettingsStore settings,
  }) : _load = load,
       _attach = attach,
       _settings = settings,
       super(PlayerState(style: settings.readSubtitleStyle()));

  final String videoId;
  final PlayerEngine engine;
  final LoadPlayerData _load;
  final AttachSubtitles _attach;
  final SettingsStore _settings;

  StreamSubscription<PlaybackSnapshot>? _sub;
  Timer? _hideTimer;

  Future<void> start() async {
    final data = await _load(videoId);
    if (data case Err(:final failure)) {
      emit(state.copyWith(status: PlayerStatus.error, failure: failure));
      return;
    }
    final d = (data as Success<PlayerData>).value;
    emit(state.copyWith(video: d.video, timeline: d.timeline));
    _sub = engine.snapshots.listen(_onSnapshot);
    await engine.open(d.video.path);
    await engine.play();
  }

  void _onSnapshot(PlaybackSnapshot s) {
    if (s.error != null) {
      emit(state.copyWith(status: PlayerStatus.error, snapshot: s));
      return;
    }
    // Active cue comes from the media position (audio time), never wall-clock.
    final cue = state.timeline.activeAt(s.position);
    emit(
      state.copyWith(
        status: s.isReady ? PlayerStatus.ready : PlayerStatus.loading,
        snapshot: s,
        activeText: cue?.text,
        clearActive: cue == null,
      ),
    );
  }

  Future<void> togglePlay() async {
    if (state.snapshot.isPlaying) {
      await engine.pause();
      _hideTimer?.cancel();
    } else {
      await engine.play();
      _scheduleHide();
    }
  }

  Future<void> seek(Duration p) => engine.seekTo(p);

  Future<void> setSpeed(double s) => engine.setSpeed(s);

  void toggleControls() {
    final show = !state.controlsVisible;
    emit(state.copyWith(controlsVisible: show));
    if (show) _scheduleHide();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(AppMotion.controlsHide, () {
      if (!isClosed && state.snapshot.isPlaying) {
        emit(state.copyWith(controlsVisible: false));
      }
    });
  }

  Future<void> updateStyle(SubtitleStyle style) async {
    emit(state.copyWith(style: style));
    await _settings.writeSubtitleStyle(style);
  }

  Future<void> attachSubtitles() async {
    final res = await _attach(videoId);
    switch (res) {
      case Err(:final failure):
        emit(state.copyWith(failure: failure));
      case Success(:final value) when value != null:
        emit(
          state.copyWith(
            timeline: value,
            video: state.video?.copyWith(
              status: VideoStatus.ready,
              origin: SubtitleOrigin.imported,
            ),
          ),
        );
      case Success():
        break;
    }
  }

  void failureShown() => emit(state.copyWith(clearFailure: true));

  @override
  Future<void> close() async {
    _hideTimer?.cancel();
    await _sub?.cancel();
    await engine.dispose();
    return super.close();
  }
}
