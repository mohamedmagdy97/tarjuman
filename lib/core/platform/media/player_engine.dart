import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class PlaybackSnapshot extends Equatable {
  const PlaybackSnapshot({
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.isReady = false,
    this.speed = 1,
    this.error,
  });

  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isReady;
  final double speed;
  final String? error;

  @override
  List<Object?> get props => [
    position,
    duration,
    isPlaying,
    isReady,
    speed,
    error,
  ];
}

/// Video playback seam. The surface widget lives here (not in domain) because
/// it must be a Flutter widget; the package behind it is an adapter detail.
abstract interface class PlayerEngine {
  Stream<PlaybackSnapshot> get snapshots;
  Future<void> open(String path);
  Future<void> play();
  Future<void> pause();
  Future<void> seekTo(Duration position);
  Future<void> setSpeed(double speed);
  Widget buildSurface();
  Future<void> dispose();
}
