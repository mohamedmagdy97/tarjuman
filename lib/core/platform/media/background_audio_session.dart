import 'dart:async';

import 'package:audio_service/audio_service.dart';

/// Hooks the player into the OS media session: notification controls,
/// lock-screen controls, headset buttons, and keeping playback alive while the
/// app is in the background.
abstract interface class BackgroundAudioSession {
  Future<void> attach({
    required String id,
    required String title,
    required BackgroundAudioControls controls,
  });

  void update({
    required bool playing,
    required Duration position,
    required Duration duration,
    required double speed,
  });

  Future<void> detach();
}

class BackgroundAudioControls {
  const BackgroundAudioControls({
    required this.play,
    required this.pause,
    required this.seek,
    required this.seekBy,
    required this.stop,
    this.next,
  });

  final Future<void> Function() play;
  final Future<void> Function() pause;
  final Future<void> Function(Duration position) seek;
  final Future<void> Function(Duration delta) seekBy;
  final Future<void> Function() stop;
  final Future<void> Function()? next;
}

class AudioServiceSession implements BackgroundAudioSession {
  _Handler? _handler;
  Future<_Handler>? _starting;

  Future<_Handler> _ensure() => _starting ??= AudioService.init(
    builder: _Handler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.megtech.tarjuman.playback',
      androidNotificationChannelName: 'Playback',
      androidNotificationOngoing: true,
    ),
  ).then((h) => _handler = h);

  @override
  Future<void> attach({
    required String id,
    required String title,
    required BackgroundAudioControls controls,
  }) async {
    try {
      final h = await _ensure();
      h.controls = controls;
      h.mediaItem.add(MediaItem(id: id, title: title));
    } on Object {
      // No media session (unsupported platform / tests): playback still works.
    }
  }

  @override
  void update({
    required bool playing,
    required Duration position,
    required Duration duration,
    required double speed,
  }) => _handler?.push(
    playing: playing,
    position: position,
    duration: duration,
    speed: speed,
  );

  @override
  Future<void> detach() async {
    final h = _handler;
    if (h == null) return;
    h.controls = null;
    try {
      await h.stop();
    } on Object {
      // Already stopped.
    }
  }
}

class _Handler extends BaseAudioHandler {
  BackgroundAudioControls? controls;
  Duration _duration = Duration.zero;

  void push({
    required bool playing,
    required Duration position,
    required Duration duration,
    required double speed,
  }) {
    if (duration != _duration && duration > Duration.zero) {
      _duration = duration;
      final item = mediaItem.value;
      if (item != null) mediaItem.add(item.copyWith(duration: duration));
    }
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.rewind,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.fastForward,
          if (controls?.next != null) MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: AudioProcessingState.ready,
        playing: playing,
        updatePosition: position,
        speed: speed,
      ),
    );
  }

  @override
  Future<void> play() async => controls?.play();
  @override
  Future<void> pause() async => controls?.pause();
  @override
  Future<void> seek(Duration position) async => controls?.seek(position);
  @override
  Future<void> fastForward() async =>
      controls?.seekBy(const Duration(seconds: 10));
  @override
  Future<void> rewind() async => controls?.seekBy(const Duration(seconds: -10));
  @override
  Future<void> skipToNext() async => controls?.next?.call();

  @override
  Future<void> stop() async {
    await controls?.stop();
    playbackState.add(
      PlaybackState(),
    );
    await super.stop();
  }
}
