import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarjuman/core/database/app_database.dart';
import 'package:tarjuman/core/platform/media/media_kit_engine.dart';
import 'package:tarjuman/core/settings/settings_store.dart';
import 'package:tarjuman/features/library/data/file_picker_media_picker.dart';
import 'package:tarjuman/features/library/data/media_storage.dart';
import 'package:tarjuman/features/library/data/video_repository_impl.dart';
import 'package:tarjuman/features/library/domain/ports/media_picker.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';
import 'package:tarjuman/features/library/domain/usecases/delete_video.dart';
import 'package:tarjuman/features/library/domain/usecases/import_video.dart';
import 'package:tarjuman/features/library/domain/usecases/watch_library.dart';
import 'package:tarjuman/features/library/presentation/cubit/library_cubit.dart';
import 'package:tarjuman/features/model_manager/data/model_repository_impl.dart';
import 'package:tarjuman/features/model_manager/domain/repositories/model_repository.dart';
import 'package:tarjuman/features/model_manager/presentation/cubit/models_cubit.dart';
import 'package:tarjuman/features/player/data/subtitle_repository_impl.dart';
import 'package:tarjuman/features/player/domain/repositories/subtitle_repository.dart';
import 'package:tarjuman/features/player/domain/services/subtitle_parser.dart';
import 'package:tarjuman/features/player/domain/usecases/attach_subtitles.dart';
import 'package:tarjuman/features/player/domain/usecases/load_player_data.dart';
import 'package:tarjuman/features/player/presentation/cubit/player_cubit.dart';
import 'package:tarjuman/features/processing/data/engine_provider_impl.dart';
import 'package:tarjuman/features/processing/data/ffmpeg_audio_extractor.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/domain/ports/audio_extractor.dart';
import 'package:tarjuman/features/processing/domain/ports/engine_provider.dart';
import 'package:tarjuman/features/processing/domain/services/cue_segmenter.dart';
import 'package:tarjuman/features/processing/domain/usecases/live_subtitle_session.dart';
import 'package:tarjuman/features/processing/domain/usecases/process_range.dart';
import 'package:tarjuman/features/processing/domain/usecases/run_processing_pipeline.dart';
import 'package:tarjuman/features/processing/presentation/cubit/processing_cubit.dart';
import 'package:tarjuman/features/processing/presentation/cubit/setup_cubit.dart';
import 'package:tarjuman/features/settings/presentation/cubit/app_settings_cubit.dart';

final GetIt sl = GetIt.instance;

/// Composition root: the only place that knows concrete implementations.
Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  sl
    ..registerSingleton<AppDatabase>(AppDatabase())
    ..registerSingleton<SettingsStore>(SharedPrefsSettingsStore(prefs))
    ..registerLazySingleton<MediaStorage>(MediaStorage.new)
    ..registerLazySingleton<MediaPicker>(FilePickerMediaPicker.new)
    ..registerLazySingleton<VideoRepository>(
      () => VideoRepositoryImpl(sl(), sl()),
    )
    ..registerLazySingleton<SubtitleRepository>(
      () => SubtitleRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => const SubtitleParser())
    ..registerFactory(() => WatchLibrary(sl()))
    ..registerFactory(() => ImportVideo(sl(), sl(), sl()))
    ..registerFactory(() => DeleteVideo(sl()))
    ..registerFactory(() => LoadPlayerData(sl(), sl()))
    ..registerFactory(() => AttachSubtitles(sl(), sl(), sl()))
    ..registerFactory(() => LibraryCubit(sl(), sl(), sl()))
    ..registerSingleton<SecretStore>(const KeystoreSecretStore())
    ..registerLazySingleton<ModelRepository>(ModelRepositoryImpl.new)
    ..registerLazySingleton<AudioExtractor>(FfmpegAudioExtractor.new)
    ..registerLazySingleton<EngineProvider>(
      () => EngineProviderImpl(sl(), sl(), sl()),
    )
    ..registerLazySingleton(() => const CueSegmenter())
    ..registerLazySingleton(() => ProcessRange(sl(), sl(), _workPath))
    ..registerFactory(
      () => RunProcessingPipeline(
        videos: sl(),
        subtitles: sl(),
        audio: sl(),
        engines: sl(),
        processRange: sl(),
      ),
    )
    ..registerFactory(() => LiveSubtitleSession(sl()))
    ..registerFactory(() => ModelsCubit(sl()))
    ..registerFactory(() => SetupCubit(sl(), sl(), sl(), sl()))
    ..registerSingleton<AppSettingsCubit>(
      AppSettingsCubit(sl(), sl()),
    );
}

Future<String> _workPath(String name) async {
  final dir = Directory(p.join((await getTemporaryDirectory()).path, 'work'));
  await dir.create(recursive: true);
  return p.join(dir.path, name);
}

ProcessingCubit newProcessingCubit(String videoId, EngineKind kind) =>
    ProcessingCubit(
      videoId: videoId,
      kind: kind,
      pipeline: sl(),
    );

/// Player cubits are per-video and own a fresh engine.
PlayerCubit newPlayerCubit(String videoId, {EngineKind? liveKind}) =>
    PlayerCubit(
      videoId: videoId,
      engine: MediaKitEngine(),
      load: sl(),
      attach: sl(),
      settings: sl(),
      engines: sl(),
      liveFactory: sl.call<LiveSubtitleSession>,
      liveKind: liveKind,
    );
