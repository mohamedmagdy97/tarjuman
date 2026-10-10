import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/core/design_system/tokens/app_motion.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/platform/device/brightness_control.dart';
import 'package:tarjuman/core/platform/media/player_engine.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/core/settings/settings_store.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_style.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_timeline.dart';
import 'package:tarjuman/features/player/domain/usecases/attach_subtitles.dart';
import 'package:tarjuman/features/player/domain/usecases/load_player_data.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/ports/engine_provider.dart';
import 'package:tarjuman/features/processing/domain/usecases/live_subtitle_session.dart';

enum PlayerStatus { loading, ready, error }

enum HudKind { seekBack, seekForward, volume, brightness, loop }

/// Transient on-screen feedback for gestures (volume bar, +10 s, ...).
class PlayerHud extends Equatable {
  const PlayerHud(this.kind, {this.value, this.label});
  final HudKind kind;

  /// 0..1 for volume/brightness bars.
  final double? value;
  final String? label;

  @override
  List<Object?> get props => [kind, value, label];
}

class PlayerState extends Equatable {
  const PlayerState({
    this.status = PlayerStatus.loading,
    this.video,
    this.timeline = const SubtitleTimeline.empty(),
    this.snapshot = const PlaybackSnapshot(),
    this.style = const SubtitleStyle(),
    this.activeText,
    this.activeOriginal,
    this.controlsVisible = true,
    this.failure,
    this.isLive = false,
    this.liveBusy = false,
    this.loopA,
    this.loopB,
    this.volume = 1,
    this.hud,
    this.subtitleOffset = Duration.zero,
  });

  final PlayerStatus status;
  final Video? video;
  final SubtitleTimeline timeline;
  final PlaybackSnapshot snapshot;
  final SubtitleStyle style;
  final String? activeText;
  final String? activeOriginal;

  final bool controlsVisible;
  final Failure? failure;
  final bool isLive;
  final bool liveBusy;

  /// A-B repeat markers (both set = looping).
  final Duration? loopA;
  final Duration? loopB;
  final double volume;
  final PlayerHud? hud;

  /// Subtitle shift for this video (positive = subtitles appear later).
  final Duration subtitleOffset;

  PlayerState copyWith({
    PlayerStatus? status,
    Video? video,
    SubtitleTimeline? timeline,
    PlaybackSnapshot? snapshot,
    SubtitleStyle? style,
    String? activeText,
    String? activeOriginal,

    bool clearActive = false,
    bool? controlsVisible,
    Failure? failure,
    bool clearFailure = false,
    bool? isLive,
    bool? liveBusy,
    Duration? loopA,
    Duration? loopB,
    bool clearLoop = false,
    double? volume,
    PlayerHud? hud,
    bool clearHud = false,
    Duration? subtitleOffset,
  }) => PlayerState(
    status: status ?? this.status,
    video: video ?? this.video,
    timeline: timeline ?? this.timeline,
    snapshot: snapshot ?? this.snapshot,
    style: style ?? this.style,
    activeText: clearActive ? null : activeText ?? this.activeText,
    activeOriginal: clearActive ? null : activeOriginal ?? this.activeOriginal,

    controlsVisible: controlsVisible ?? this.controlsVisible,
    failure: clearFailure ? null : failure ?? this.failure,
    isLive: isLive ?? this.isLive,
    liveBusy: liveBusy ?? this.liveBusy,
    loopA: clearLoop ? null : loopA ?? this.loopA,
    loopB: clearLoop ? null : loopB ?? this.loopB,
    volume: volume ?? this.volume,
    hud: clearHud ? null : hud ?? this.hud,
    subtitleOffset: subtitleOffset ?? this.subtitleOffset,
  );

  @override
  List<Object?> get props => [
    status,
    video,
    timeline.cues.length,
    snapshot,
    style,
    activeText,
    activeOriginal,
    controlsVisible,
    failure,
    isLive,
    liveBusy,
    loopA,
    loopB,
    volume,
    hud,
    subtitleOffset,
  ];
}

class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit({
    required this.videoId,
    required VideoRepository videos,

    required this.engine,
    required BrightnessControl brightness,
    required LoadPlayerData load,
    required AttachSubtitles attach,
    required SettingsStore settings,
    required EngineProvider engines,
    required LiveSubtitleSession Function() liveFactory,
    this.liveKind,
    this.liveLanguage = SourceLanguage.en,
    this.startAt,
  }) : _brightness = brightness,
       _videos = videos,
       _load = load,
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
  final VideoRepository _videos;
  final BrightnessControl _brightness;
  Timer? _hudTimer;
  double? _brightnessLevel;

  /// Explicit start position (e.g. jump from the editor); null = resume.
  final Duration? startAt;
  Timer? _saveTimer;

  final EngineProvider _engines;
  final LiveSubtitleSession Function() _liveFactory;
  final EngineKind? liveKind;
  final SourceLanguage liveLanguage;

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
    emit(
      state.copyWith(
        video: d.video,
        timeline: d.timeline,
        subtitleOffset: _settings.readSubtitleOffset(videoId),
      ),
    );
    _sub = engine.snapshots.listen(_onSnapshot);
    await engine.open(d.video.path);
    _saveTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _savePosition(),
    );
    final resume = startAt ?? d.video.lastPosition;
    if (resume > const Duration(seconds: 5)) {
      await _awaitReady();
      await engine.seekTo(resume);
    }
    await engine.play();
  }

  Future<void> _awaitReady() async {
    if (state.snapshot.isReady) return;
    await engine.snapshots
        .firstWhere((s) => s.isReady)
        .timeout(const Duration(seconds: 10), onTimeout: () => state.snapshot);
  }

  void _savePosition() {
    final s = state.snapshot;
    if (!s.isReady || state.video == null) return;
    // Near the end = finished: restart from the beginning next time.
    final done = s.duration - s.position < const Duration(seconds: 10);
    unawaited(
      _videos.savePosition(videoId, done ? Duration.zero : s.position),
    );
  }

  void _onSnapshot(PlaybackSnapshot s) {
    if (s.error != null) {
      emit(state.copyWith(status: PlayerStatus.error, snapshot: s));
      return;
    }
    _session?.onPosition(s.position);
    final a = state.loopA;
    final b = state.loopB;
    if (a != null && b != null && s.position >= b) {
      unawaited(engine.seekTo(a));
    }
    if (liveKind != null && s.isReady && _session == null && !_liveStarting) {
      _liveStarting = true;
      unawaited(_startLive(s.duration, s.position));
    }
    // Active cue comes from the media position (audio time), never wall-clock.
    final cue = state.timeline.activeAt(s.position - state.subtitleOffset);
    emit(
      state.copyWith(
        status: s.isReady ? PlayerStatus.ready : PlayerStatus.loading,
        snapshot: s,
        activeText: cue?.text,
        activeOriginal: cue?.original,
        clearActive: cue == null,
      ),
    );
  }

  Future<void> _startLive(Duration total, Duration position) async {
    final acquired = await _engines.acquire(liveKind!, language: liveLanguage);
    if (acquired case Err(:final failure)) {
      emit(state.copyWith(failure: failure));
      return;
    }
    final session = _liveFactory();
    _liveSub = session.updates.listen((u) {
      final cue = u.timeline.activeAt(
        state.snapshot.position - state.subtitleOffset,
      );
      emit(
        state.copyWith(
          timeline: u.timeline,
          liveBusy: u.busy,
          failure: u.failure,
          activeText: cue?.text,
          activeOriginal: cue?.original,
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

  // ---- gestures ----------------------------------------------------------

  void _showHud(PlayerHud hud) {
    _hudTimer?.cancel();
    emit(state.copyWith(hud: hud));
    _hudTimer = Timer(const Duration(milliseconds: 900), () {
      if (!isClosed) emit(state.copyWith(clearHud: true));
    });
  }

  Future<void> seekBy(Duration delta) async {
    final s = state.snapshot;
    final target = s.position + delta;
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > s.duration ? s.duration : target);
    await engine.seekTo(clamped);
    _showHud(
      PlayerHud(
        delta.isNegative ? HudKind.seekBack : HudKind.seekForward,
        label: '${delta.inSeconds.abs()}',
      ),
    );
  }

  Future<void> adjustVolume(double delta) async {
    final v = (state.volume + delta).clamp(0.0, 1.0);
    emit(state.copyWith(volume: v));
    await engine.setVolume(v);
    _showHud(PlayerHud(HudKind.volume, value: v));
  }

  Future<void> adjustBrightness(double delta) async {
    final current = _brightnessLevel ?? await _brightness.current();
    final v = (current + delta).clamp(0.02, 1.0);
    _brightnessLevel = v;
    await _brightness.set(v);
    _showHud(PlayerHud(HudKind.brightness, value: v));
  }

  /// A-B repeat: tap once to set A, again to set B (loop starts), again to clear.
  void cycleLoop() {
    final pos = state.snapshot.position;
    if (state.loopA == null) {
      emit(state.copyWith(loopA: pos));
      _showHud(const PlayerHud(HudKind.loop, label: 'A'));
    } else if (state.loopB == null) {
      if (pos <= state.loopA!) return;
      emit(state.copyWith(loopB: pos));
      _showHud(const PlayerHud(HudKind.loop, label: 'A-B'));
    } else {
      emit(state.copyWith(clearLoop: true));
      _showHud(const PlayerHud(HudKind.loop, label: '—'));
    }
  }

  Future<void> adjustSubtitleOffset(Duration delta) async {
    final next = state.subtitleOffset + delta;
    emit(state.copyWith(subtitleOffset: next));
    await _settings.writeSubtitleOffset(videoId, next);
  }

  Future<void> resetSubtitleOffset() async {
    emit(state.copyWith(subtitleOffset: Duration.zero));
    await _settings.writeSubtitleOffset(videoId, Duration.zero);
  }

  // ---- study mode --------------------------------------------------------

  SubtitleCue? get _currentCue =>
      state.timeline.activeAt(state.snapshot.position - state.subtitleOffset);

  /// Jump to the previous sentence (or restart the current one if it is
  /// more than 2 s in).
  Future<void> previousCue() async {
    final cues = state.timeline.cues;
    final pos = state.snapshot.position - state.subtitleOffset;
    for (var i = cues.length - 1; i >= 0; i--) {
      final threshold = cues[i].start + const Duration(seconds: 2);
      if (threshold < pos) {
        await engine.seekTo(cues[i].start + state.subtitleOffset);
        return;
      }
    }
    await engine.seekTo(Duration.zero);
  }

  Future<void> nextCue() async {
    final pos = state.snapshot.position - state.subtitleOffset;
    for (final c in state.timeline.cues) {
      if (c.start > pos) {
        await engine.seekTo(c.start + state.subtitleOffset);
        return;
      }
    }
  }

  /// Loops the sentence on screen (A-B markers) until toggled off.
  Future<void> repeatCurrentCue() async {
    if (state.loopA != null && state.loopB != null) {
      emit(state.copyWith(clearLoop: true));
      return;
    }
    final cue = _currentCue;
    if (cue == null) return;
    emit(
      state.copyWith(
        loopA: cue.start + state.subtitleOffset,
        loopB: cue.end + state.subtitleOffset,
      ),
    );
    await engine.seekTo(cue.start + state.subtitleOffset);
    _showHud(const PlayerHud(HudKind.loop, label: '↻'));
  }

  Future<void> selectAudio(String id) => engine.setAudioTrack(id);

  Future<void> selectSubtitleTrack(String? id) => engine.setSubtitleTrack(id);

  @override
  Future<void> close() async {
    _saveTimer?.cancel();
    _savePosition();
    _hideTimer?.cancel();
    _hudTimer?.cancel();
    unawaited(_brightness.reset());
    await _sub?.cancel();
    await _liveSub?.cancel();
    await _session?.stop();
    await engine.dispose();
    return super.close();
  }
}
