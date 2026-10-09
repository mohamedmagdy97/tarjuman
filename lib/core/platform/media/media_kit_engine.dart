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
    ];
  }

  final Player _player = Player();
  late final VideoController _controller;
  late final List<StreamSubscription<Object?>> _subs;
  final _out = StreamController<PlaybackSnapshot>.broadcast();
  var _snap = const PlaybackSnapshot();

  @override
  Stream<PlaybackSnapshot> get snapshots => _out.stream;

  void _update({
    Duration? position,
    Duration? duration,
    bool? playing,
    double? speed,
    String? error,
  }) {
    final d = duration ?? _snap.duration;
    _snap = PlaybackSnapshot(
      position: position ?? _snap.position,
      duration: d,
      isPlaying: playing ?? _snap.isPlaying,
      isReady: d > Duration.zero,
      speed: speed ?? _snap.speed,
      error: error ?? _snap.error,
    );
    if (!_out.isClosed) _out.add(_snap);
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
