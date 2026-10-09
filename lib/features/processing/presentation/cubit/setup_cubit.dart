import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/core/settings/settings_store.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';
import 'package:tarjuman/features/model_manager/domain/repositories/model_repository.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';

class SetupState extends Equatable {
  const SetupState({
    this.video,
    this.mode = ProcessingMode.prepare,
    this.engine = EngineKind.offline,
    this.offlineReady = false,
    this.onlineReady = false,
    this.loading = true,
  });

  final Video? video;
  final ProcessingMode mode;
  final EngineKind engine;
  final bool offlineReady;
  final bool onlineReady;
  final bool loading;

  bool get canStart =>
      !loading && (engine == EngineKind.offline ? offlineReady : onlineReady);

  SetupState copyWith({
    Video? video,
    ProcessingMode? mode,
    EngineKind? engine,
    bool? offlineReady,
    bool? onlineReady,
    bool? loading,
  }) => SetupState(
    video: video ?? this.video,
    mode: mode ?? this.mode,
    engine: engine ?? this.engine,
    offlineReady: offlineReady ?? this.offlineReady,
    onlineReady: onlineReady ?? this.onlineReady,
    loading: loading ?? this.loading,
  );

  @override
  List<Object?> get props => [
    video,
    mode,
    engine,
    offlineReady,
    onlineReady,
    loading,
  ];
}

class SetupCubit extends Cubit<SetupState> {
  SetupCubit(this._videos, this._models, this._settings, this._secrets)
    : super(const SetupState());

  final VideoRepository _videos;
  final ModelRepository _models;
  final SettingsStore _settings;
  final SecretStore _secrets;

  /// Re-checks readiness; call again after returning from the models page.
  Future<void> load(String videoId) async {
    final video = await _videos.get(videoId);
    final speech = await _models.installedSpeechModelPath() != null;
    final translation = await _models.translationReady();
    final key = await _secrets.readApiKey();
    emit(
      state.copyWith(
        video: video is Success<Video> ? video.value : null,
        offlineReady: speech && translation,
        onlineReady:
            _settings.readOnlineConsent() && key != null && key.isNotEmpty,
        loading: false,
      ),
    );
  }

  void setMode(ProcessingMode m) => emit(state.copyWith(mode: m));
  void setEngine(EngineKind e) => emit(state.copyWith(engine: e));
}
