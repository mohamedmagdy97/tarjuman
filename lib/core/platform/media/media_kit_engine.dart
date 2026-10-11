import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:tarjuman/core/platform/media/player_engine.dart';

/// libmpv-based playback: plays practically any container/codec
/// (mkv, avi, mov, wmv, flv, ts, 3gp, webm, mp4, audio-only files...).
class MediaKitEngine implements PlayerEngine {
  MediaKitEngine() {
    _controller = VideoController(_player);
    _subs = [
      _player.stream.position.listen((v) => _update(position: v)),
      _player.stream.duration.listen((v) => _update(duration: v)),
      _player.stream.playing.listen((v) => _update(playing: v)),
      _player.stream.rate.listen((v) => _update(speed: v)),
      _player.stream.error.listen((e) => _update(error: e)),
      _player.stream.tracks.listen(_onTracks),
      _player.stream.track.listen(_onTrack),
    ];
  }

  final Player _player = Player();
  late final VideoController _controller;
  late final List<StreamSubscription<Object?>> _subs;
  final _out = StreamController<PlaybackSnapshot>.broadcast();
  var _snap = const PlaybackSnapshot();

  // Cache of real track objects so selection can pass them back to mpv.
  final _audio = <String, AudioTrack>{};
  final _subtitle = <String, SubtitleTrack>{};

  @override
  Stream<PlaybackSnapshot> get snapshots => _out.stream;

  void _emit(PlaybackSnapshot s) {
    _snap = s;
    if (!_out.isClosed) _out.add(s);
  }

  void _update({
    Duration? position,
    Duration? duration,
    bool? playing,
    double? speed,
    String? error,
  }) {
    final d = duration ?? _snap.duration;
    _emit(
      PlaybackSnapshot(
        position: position ?? _snap.position,
        duration: d,
        isPlaying: playing ?? _snap.isPlaying,
        isReady: d > Duration.zero,
        speed: speed ?? _snap.speed,
        error: error ?? _snap.error,
        audioTracks: _snap.audioTracks,
        subtitleTracks: _snap.subtitleTracks,
        selectedAudio: _snap.selectedAudio,
        selectedSubtitle: _snap.selectedSubtitle,
      ),
    );
  }

  String _label(String id, String? title, String? language, int index) {
    final parts = [
      if (title != null && title.isNotEmpty) title,
      if (language != null && language.isNotEmpty) language,
    ];
    return parts.isEmpty ? '#$index' : parts.join(' · ');
  }

  void _onTracks(Tracks tracks) {
    _audio
      ..clear()
      ..addEntries(
        tracks.audio
            .where((t) => t.id != 'auto' && t.id != 'no')
            .map((t) => MapEntry(t.id, t)),
      );
    _subtitle
      ..clear()
      ..addEntries(
        tracks.subtitle
            .where((t) => t.id != 'auto' && t.id != 'no')
            .map((t) => MapEntry(t.id, t)),
      );
    var i = 0;
    final audio = [
      for (final t in _audio.values)
        MediaTrack(id: t.id, label: _label(t.id, t.title, t.language, ++i)),
    ];
    i = 0;
    final subs = [
      for (final t in _subtitle.values)
        MediaTrack(id: t.id, label: _label(t.id, t.title, t.language, ++i)),
    ];
    _emit(
      PlaybackSnapshot(
        position: _snap.position,
        duration: _snap.duration,
        isPlaying: _snap.isPlaying,
        isReady: _snap.isReady,
        speed: _snap.speed,
        error: _snap.error,
        audioTracks: audio,
        subtitleTracks: subs,
        selectedAudio: _snap.selectedAudio,
        selectedSubtitle: _snap.selectedSubtitle,
      ),
    );
  }

  void _onTrack(Track track) {
    String? sel(String id) => id == 'auto' || id == 'no' ? null : id;
    _emit(
      PlaybackSnapshot(
        position: _snap.position,
        duration: _snap.duration,
        isPlaying: _snap.isPlaying,
        isReady: _snap.isReady,
        speed: _snap.speed,
        error: _snap.error,
        audioTracks: _snap.audioTracks,
        subtitleTracks: _snap.subtitleTracks,
        selectedAudio: sel(track.audio.id),
        selectedSubtitle: sel(track.subtitle.id),
      ),
    );
  }

  @override
  Future<void> open(String path) => _player.open(Media(path), play: false);

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seekTo(Duration position) => _player.seek(position);

  @override
  Future<void> setSpeed(double speed) => _player.setRate(speed);

  @override
  Future<void> setVolume(double volume) =>
      _player.setVolume(volume.clamp(0, 1) * 100);

  @override
  Future<void> setAudioTrack(String id) async {
    final t = _audio[id];
    if (t != null) await _player.setAudioTrack(t);
  }

  @override
  Future<void> setSubtitleTrack(String? id) async {
    if (id == null) return _player.setSubtitleTrack(SubtitleTrack.no());
    final t = _subtitle[id];
    if (t != null) await _player.setSubtitleTrack(t);
  }

  @override
  Future<void> setVideoEnabled({required bool enabled}) =>
      _player.setVideoTrack(enabled ? VideoTrack.auto() : VideoTrack.no());

  @override
  Widget buildSurface() => Video(
    controller: _controller,
    controls: (_) => const SizedBox.shrink(),
  );

  @override
  Future<void> dispose() async {
    for (final s in _subs) {
      await s.cancel();
    }
    await _player.dispose();
    await _out.close();
  }
}
