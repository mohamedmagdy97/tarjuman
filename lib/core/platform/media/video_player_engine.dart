import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:tarjuman/core/platform/media/player_engine.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerEngine implements PlayerEngine {
  VideoPlayerController? _controller;
  final _out = StreamController<PlaybackSnapshot>.broadcast();

  @override
  Stream<PlaybackSnapshot> get snapshots => _out.stream;

  @override
  Future<void> open(String path) async {
    final c = VideoPlayerController.file(File(path));
    _controller = c;
    c.addListener(_emit);
    try {
      await c.initialize();
    } on Object catch (e) {
      _out.add(PlaybackSnapshot(error: e.toString()));
      return;
    }
    _emit();
  }

  void _emit() {
    final v = _controller?.value;
    if (v == null) return;
    _out.add(
      PlaybackSnapshot(
        position: v.position,
        duration: v.duration,
        isPlaying: v.isPlaying,
        isReady: v.isInitialized,
        speed: v.playbackSpeed,
        error: v.errorDescription,
      ),
    );
  }

  @override
  Future<void> play() async => _controller?.play();

  @override
  Future<void> pause() async => _controller?.pause();

  @override
  Future<void> seekTo(Duration position) async => _controller?.seekTo(position);

  @override
  Future<void> setSpeed(double speed) async =>
      _controller?.setPlaybackSpeed(speed);

  @override
  Widget buildSurface() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return const SizedBox.shrink();
    return Center(
      child: AspectRatio(
        aspectRatio: c.value.aspectRatio,
        child: VideoPlayer(c),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    _controller?.removeListener(_emit);
    await _controller?.dispose();
    await _out.close();
  }
}
