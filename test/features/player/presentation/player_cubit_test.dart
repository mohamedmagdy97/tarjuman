// Reason: tests drive the cubit with sequential emit/act calls on purpose.
// ignore_for_file: cascade_invocations
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarjuman/core/platform/device/brightness_control.dart';
import 'package:tarjuman/core/platform/media/player_engine.dart';
import 'package:tarjuman/core/settings/settings_store.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_style.dart';
import 'package:tarjuman/features/player/domain/usecases/attach_subtitles.dart';
import 'package:tarjuman/features/player/domain/usecases/load_player_data.dart';
import 'package:tarjuman/features/player/presentation/cubit/player_cubit.dart';
import 'package:tarjuman/features/processing/domain/ports/engine_provider.dart';
import 'package:tarjuman/features/processing/domain/usecases/live_subtitle_session.dart';

class _Engine implements PlayerEngine {
  final snapshotsCtl = StreamController<PlaybackSnapshot>.broadcast();
  final seeks = <Duration>[];
  double? volume;

  @override
  Stream<PlaybackSnapshot> get snapshots => snapshotsCtl.stream;
  @override
  Future<void> open(String path) async {}
  @override
  Future<void> play() async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> seekTo(Duration position) async => seeks.add(position);
  @override
  Future<void> setSpeed(double speed) async {}
  @override
  Future<void> setVolume(double v) async => volume = v;
  @override
  Future<void> setAudioTrack(String id) async {}
  @override
  Future<void> setSubtitleTrack(String? id) async {}
  @override
  Widget buildSurface() => const SizedBox.shrink();
  @override
  Future<void> dispose() async {}
}

class _Settings implements SettingsStore {
  @override
  SubtitleStyle readSubtitleStyle() => const SubtitleStyle();
  @override
  Future<void> writeSubtitleStyle(SubtitleStyle style) async {}
  @override
  ThemeMode readThemeMode() => ThemeMode.dark;
  @override
  Future<void> writeThemeMode(ThemeMode mode) async {}
  @override
  bool readOnlineConsent() => false;
  @override
  Future<void> writeOnlineConsent({required bool value}) async {}
}

class _Brightness implements BrightnessControl {
  double? last;
  @override
  Future<double> current() async => .5;
  @override
  Future<void> set(double value) async => last = value;
  @override
  Future<void> reset() async {}
}

class _MVideos extends Mock implements VideoRepository {}

class _MLoad extends Mock implements LoadPlayerData {}

class _MAttach extends Mock implements AttachSubtitles {}

class _MEngines extends Mock implements EngineProvider {}

class _MLive extends Mock implements LiveSubtitleSession {}

PlaybackSnapshot snap(int seconds, {int total = 100}) => PlaybackSnapshot(
  position: Duration(seconds: seconds),
  duration: Duration(seconds: total),
  isReady: true,
  isPlaying: true,
);

void main() {
  late _Engine engine;
  late _Brightness brightness;
  late PlayerCubit cubit;

  setUp(() {
    engine = _Engine();
    brightness = _Brightness();
    cubit = PlayerCubit(
      videoId: 'v',
      videos: _MVideos(),
      engine: engine,
      brightness: brightness,
      load: _MLoad(),
      attach: _MAttach(),
      settings: _Settings(),
      engines: _MEngines(),
      liveFactory: _MLive.new,
    );
    // Feed the cubit the way start() would.
    cubit.emit(cubit.state.copyWith(snapshot: snap(50)));
  });
  tearDown(() => cubit.close());

  test(
    'seekBy moves relative to position and clamps to the media bounds',
    () async {
      await cubit.seekBy(const Duration(seconds: 10));
      await cubit.seekBy(const Duration(seconds: -200));
      cubit.emit(cubit.state.copyWith(snapshot: snap(95)));
      await cubit.seekBy(const Duration(seconds: 30));
      expect(engine.seeks, [
        const Duration(seconds: 60),
        Duration.zero,
        const Duration(seconds: 100),
      ]);
      expect(cubit.state.hud?.kind, HudKind.seekForward);
    },
  );

  test('volume is clamped to 0..1 and forwarded to the engine', () async {
    await cubit.adjustVolume(2);
    expect(engine.volume, 1);
    await cubit.adjustVolume(-3);
    expect(engine.volume, 0);
    expect(cubit.state.volume, 0);
  });

  test(
    'brightness is adjusted through the port, never below the floor',
    () async {
      await cubit.adjustBrightness(-2);
      expect(brightness.last, 0.02);
      await cubit.adjustBrightness(5);
      expect(brightness.last, 1);
    },
  );

  test('A-B repeat: set A, set B, then clear', () {
    cubit.emit(cubit.state.copyWith(snapshot: snap(10)));
    cubit.cycleLoop();
    expect(cubit.state.loopA, const Duration(seconds: 10));
    expect(cubit.state.loopB, isNull);

    cubit.emit(cubit.state.copyWith(snapshot: snap(5)));
    cubit.cycleLoop(); // B must be after A: ignored
    expect(cubit.state.loopB, isNull);

    cubit.emit(cubit.state.copyWith(snapshot: snap(20)));
    cubit.cycleLoop();
    expect(cubit.state.loopB, const Duration(seconds: 20));

    cubit.cycleLoop();
    expect(cubit.state.loopA, isNull);
    expect(cubit.state.loopB, isNull);
  });
}
