import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class MediaTrack extends Equatable {
  const MediaTrack({required this.id, required this.label});
  final String id;
  final String label;

  @override
  List<Object?> get props => [id, label];
}

class PlaybackSnapshot extends Equatable {
  const PlaybackSnapshot({
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.isReady = false,
    this.speed = 1,
    this.error,
    this.audioTracks = const [],
    this.subtitleTracks = const [],
    this.selectedAudio,
    this.selectedSubtitle,
  });

  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isReady;
  final double speed;
  final String? error;

  /// Embedded tracks (the auto/off pseudo-tracks are filtered out).
  final List<MediaTrack> audioTracks;
  final List<MediaTrack> subtitleTracks;
  final String? selectedAudio;

  /// null = embedded subtitles off.
  final String? selectedSubtitle;

  @override
  List<Object?> get props => [
    position,
    duration,
    isPlaying,
    isReady,
    speed,
    error,
    audioTracks,
    subtitleTracks,
    selectedAudio,
    selectedSubtitle,
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

  /// 0..1
  Future<void> setVolume(double volume);
  Future<void> setAudioTrack(String id);

  /// null turns embedded subtitles off.
  Future<void> setSubtitleTrack(String? id);
  Widget buildSurface();
  Future<void> dispose();
}
