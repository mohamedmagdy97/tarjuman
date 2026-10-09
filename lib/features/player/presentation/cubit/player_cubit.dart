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
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/domain/ports/engine_provider.dart';
import 'package:tarjuman/features/processing/domain/usecases/live_subtitle_session.dart';

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
    this.isLive = false,
    this.liveBusy = false,
  });

  final PlayerStatus status;
  final Video? video;
  final SubtitleTimeline timeline;
  final PlaybackSnapshot snapshot;
  final SubtitleStyle style;
  final String? activeText;
  final bool controlsVisible;
  final Failure? failure;
  final bool isLive;
  final bool liveBusy;

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
    bool? isLive,
    bool? liveBusy,
  }) => PlayerState(
    status: status ?? this.status,
    video: video ?? this.video,
    timeline: timeline ?? this.timeline,
    snapshot: snapshot ?? this.snapshot,
    style: style ?? this.style,
    activeText: clearActive ? null : activeText ?? this.activeText,
    controlsVisible: controlsVisible ?? this.controlsVisible,
    failure: clearFailure ? null : failure ?? this.failure,
    isLive: isLive ?? this.isLive,
    liveBusy: liveBusy ?? this.liveBusy,
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
    isLive,
    liveBusy,
  ];
}

class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit({
    required this.videoId,
    required this.engine,
    required LoadPlayerData load,
    required AttachSubtitles attach,
    required SettingsStore settings,
    required EngineProvider engines,
    required LiveSubtitleSession Function() liveFactory,
    this.liveKind,
  }) : _load = load,
       _attach = attach,
       _settings = settings,
       _engines = engines,
       _liveFactory = liveFactory,
       super(
         PlayerState(
           style: settings.readSubtitleStyle(),
           isLive: liveKind != null,
         ),
       );

  final String videoId;
  final PlayerEngine engine;
  final LoadPlayerData _load;
  final AttachSubtitles _attach;
  final SettingsStore _settings;
  final EngineProvider _engines;
  final LiveSubtitleSession Function() _liveFactory;
  final EngineKind? liveKind;

  LiveSubtitleSession? _session;
  StreamSubscription<LiveUpdate>? _liveSub;
  var _liveStarting = false;
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
    _session?.onPosition(s.position);
    if (liveKind != null && s.isReady && _session == null && !_liveStarting) {
      _liveStarting = true;
      unawaited(_startLive(s.duration, s.position));
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

  Future<void> _startLive(Duration total, Duration position) async {
    final acquired = await _engines.acquire(liveKind!);
    if (acquired case Err(:final failure)) {
      emit(state.copyWith(failure: failure));
      return;
    }
    final session = _liveFactory();
    _liveSub = session.updates.listen((u) {
      final cue = u.timeline.activeAt(state.snapshot.position);
      emit(
        state.copyWith(
          timeline: u.timeline,
          liveBusy: u.busy,
          failure: u.failure,
          activeText: cue?.text,
          clearActive: cue == null,
        ),
      );
    });
    _session = session
      ..start(
        mediaPath: state.video!.path,
        engines: (acquired as Success<EngineSet>).value,
        total: total,
        position: position,
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
    await _liveSub?.cancel();
    await _session?.stop();
    await engine.dispose();
    return super.close();
  }
}
