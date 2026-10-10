import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/core/settings/settings_store.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';
import 'package:tarjuman/features/model_manager/domain/repositories/model_repository.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/ports/online_config.dart';
import 'package:tarjuman/features/processing/domain/usecases/detect_language.dart';

class SetupState extends Equatable {
  const SetupState({
    this.video,
    this.mode = ProcessingMode.prepare,
    this.engine = EngineKind.offline,
    this.language = SourceLanguage.en,
    this.offlineReady = false,
    this.onlineReady = false,
    this.loading = true,
    this.detecting = false,
    this.detectFailure,
    this.detected = false,
  });

  final Video? video;
  final ProcessingMode mode;
  final EngineKind engine;
  final SourceLanguage language;
  final bool offlineReady;
  final bool onlineReady;
  final bool loading;
  final bool detecting;

  /// Why the last language detection failed (null = fine / not tried).
  final Failure? detectFailure;

  /// The current language was chosen by detection (not by the user).
  final bool detected;

  bool get canStart =>
      !loading && (engine == EngineKind.offline ? offlineReady : onlineReady);

  SetupState copyWith({
    Video? video,
    ProcessingMode? mode,
    EngineKind? engine,
    SourceLanguage? language,
    bool? offlineReady,
    bool? onlineReady,
    bool? loading,
    bool? detecting,
    Failure? detectFailure,
    bool clearDetectFailure = false,
    bool? detected,
  }) => SetupState(
    video: video ?? this.video,
    mode: mode ?? this.mode,
    engine: engine ?? this.engine,
    language: language ?? this.language,
    offlineReady: offlineReady ?? this.offlineReady,
    onlineReady: onlineReady ?? this.onlineReady,
    loading: loading ?? this.loading,
    detecting: detecting ?? this.detecting,
    detectFailure: clearDetectFailure
        ? null
        : detectFailure ?? this.detectFailure,
    detected: detected ?? this.detected,
  );

  @override
  List<Object?> get props => [
    video,
    mode,
    engine,
    language,
    offlineReady,
    onlineReady,
    loading,
    detecting,
    detectFailure?.runtimeType,
    detected,
  ];
}

class SetupCubit extends Cubit<SetupState> {
  SetupCubit(
    this._videos,
    this._models,
    this._settings,
    this._online,
    this._detect,
  ) : super(const SetupState());

  final VideoRepository _videos;
  final ModelRepository _models;
  final SettingsStore _settings;
  final OnlineConfig _online;
  final DetectLanguage _detect;

  /// Re-checks readiness; call again after returning from the models page.
  Future<void> load(String videoId) async {
    final video = await _videos.get(videoId);
    final language = SourceLanguage.fromCode(_settings.readSourceLanguage());
    emit(
      state.copyWith(
        video: video is Success<Video> ? video.value : null,
        language: language,
        offlineReady: await _offlineReady(language),
        onlineReady: await _online.isReady(),
        loading: false,
      ),
    );
  }

  Future<bool> _offlineReady(SourceLanguage language) async =>
      await _models.installedSpeechModelPath(language) != null &&
      await _models.translationReady(language);

  /// Listens to the video and picks the spoken language for the user.
  Future<void> detectLanguage() async {
    final video = state.video;
    if (video == null || state.detecting) return;
    emit(state.copyWith(detecting: true, clearDetectFailure: true));
    final res = await _detect(
      mediaPath: video.path,
      total: video.duration ?? const Duration(minutes: 1),
    );
    switch (res) {
      case Success(:final value):
        await setLanguage(value, detected: true);
        emit(state.copyWith(detecting: false));
      case Err(:final failure):
        emit(state.copyWith(detecting: false, detectFailure: failure));
    }
  }

  Future<void> setLanguage(
    SourceLanguage language, {
    bool detected = false,
  }) async {
    await _settings.writeSourceLanguage(language.code);
    emit(
      state.copyWith(
        language: language,
        detected: detected,
        clearDetectFailure: true,
        offlineReady: await _offlineReady(language),
      ),
    );
  }

  void setMode(ProcessingMode m) => emit(state.copyWith(mode: m));
  void setEngine(EngineKind e) => emit(state.copyWith(engine: e));
}
