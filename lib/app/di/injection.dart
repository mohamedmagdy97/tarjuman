import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarjuman/app/downloads_system_bridge.dart';
import 'package:tarjuman/app/incoming_media_handler.dart';
import 'package:tarjuman/app/router.dart';
import 'package:tarjuman/core/database/app_database.dart';
import 'package:tarjuman/core/platform/background/background_processing.dart';
import 'package:tarjuman/core/platform/device/brightness_control.dart';
import 'package:tarjuman/core/platform/device/device_capability.dart';
import 'package:tarjuman/core/platform/media/media_kit_engine.dart';
import 'package:tarjuman/core/platform/notifications/app_notifier.dart';
import 'package:tarjuman/core/platform/share/incoming_media.dart';
import 'package:tarjuman/core/platform/speech/pronouncer.dart';
import 'package:tarjuman/core/settings/settings_store.dart';
import 'package:tarjuman/features/downloads/presentation/cubit/downloads_cubit.dart';
import 'package:tarjuman/features/glossary/data/glossary_repository_impl.dart';
import 'package:tarjuman/features/glossary/domain/repositories/glossary_repository.dart';
import 'package:tarjuman/features/library/data/file_picker_media_picker.dart';
import 'package:tarjuman/features/library/data/http_file_downloader.dart';
import 'package:tarjuman/features/library/data/links/composite_link_resolver.dart';
import 'package:tarjuman/features/library/data/media_storage.dart';
import 'package:tarjuman/features/library/data/platform_media_exporter.dart';
import 'package:tarjuman/features/library/data/video_repository_impl.dart';
import 'package:tarjuman/features/library/domain/ports/file_downloader.dart';
import 'package:tarjuman/features/library/domain/ports/link_source.dart';
import 'package:tarjuman/features/library/domain/ports/media_exporter.dart';
import 'package:tarjuman/features/library/domain/ports/media_picker.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';
import 'package:tarjuman/features/library/domain/usecases/delete_video.dart';
import 'package:tarjuman/features/library/domain/usecases/export_video_file.dart';
import 'package:tarjuman/features/library/domain/usecases/import_from_url.dart';
import 'package:tarjuman/features/library/domain/usecases/import_shared_media.dart';
import 'package:tarjuman/features/library/domain/usecases/import_video.dart';
import 'package:tarjuman/features/library/domain/usecases/toggle_favorite.dart';
import 'package:tarjuman/features/library/domain/usecases/watch_library.dart';
import 'package:tarjuman/features/library/presentation/cubit/library_cubit.dart';
import 'package:tarjuman/features/model_manager/data/model_repository_impl.dart';
import 'package:tarjuman/features/model_manager/domain/repositories/model_repository.dart';
import 'package:tarjuman/features/model_manager/presentation/cubit/models_cubit.dart';
import 'package:tarjuman/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:tarjuman/features/player/data/subtitle_repository_impl.dart';
import 'package:tarjuman/features/player/domain/repositories/subtitle_repository.dart';
import 'package:tarjuman/features/player/domain/services/subtitle_parser.dart';
import 'package:tarjuman/features/player/domain/services/subtitle_serializer.dart';
import 'package:tarjuman/features/player/domain/usecases/attach_subtitles.dart';
import 'package:tarjuman/features/player/domain/usecases/load_player_data.dart';
import 'package:tarjuman/features/player/domain/usecases/search_subtitles.dart';
import 'package:tarjuman/features/player/presentation/cubit/player_cubit.dart';
import 'package:tarjuman/features/processing/data/engine_provider_impl.dart';
import 'package:tarjuman/features/processing/data/ffmpeg_audio_extractor.dart';
import 'package:tarjuman/features/processing/data/online/online_engines.dart';
import 'package:tarjuman/features/processing/data/online/settings_online_config.dart';
import 'package:tarjuman/features/processing/data/whisper_language_detector.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/ports/audio_extractor.dart';
import 'package:tarjuman/features/processing/domain/ports/engine_provider.dart';
import 'package:tarjuman/features/processing/domain/ports/language_detector.dart';
import 'package:tarjuman/features/processing/domain/ports/online_config.dart';
import 'package:tarjuman/features/processing/domain/services/cue_segmenter.dart';
import 'package:tarjuman/features/processing/domain/usecases/detect_language.dart';
import 'package:tarjuman/features/processing/domain/usecases/live_subtitle_session.dart';
import 'package:tarjuman/features/processing/domain/usecases/process_range.dart';
import 'package:tarjuman/features/processing/domain/usecases/run_processing_pipeline.dart';
import 'package:tarjuman/features/processing/presentation/cubit/processing_cubit.dart';
import 'package:tarjuman/features/processing/presentation/cubit/setup_cubit.dart';
import 'package:tarjuman/features/settings/presentation/cubit/app_settings_cubit.dart';
import 'package:tarjuman/features/storage/data/file_storage_inspector.dart';
import 'package:tarjuman/features/storage/domain/ports/storage_inspector.dart';
import 'package:tarjuman/features/storage/presentation/cubit/storage_cubit.dart';
import 'package:tarjuman/features/subtitle_editor/data/share_plus_subtitle_exporter.dart';
import 'package:tarjuman/features/subtitle_editor/domain/ports/subtitle_exporter.dart';
import 'package:tarjuman/features/subtitle_editor/domain/usecases/edit_cue_text.dart';
import 'package:tarjuman/features/subtitle_editor/domain/usecases/export_subtitles.dart';
import 'package:tarjuman/features/subtitle_editor/domain/usecases/retranslate_cue.dart';
import 'package:tarjuman/features/subtitle_editor/presentation/cubit/editor_cubit.dart';
import 'package:tarjuman/features/transcript/domain/usecases/export_transcript.dart';
import 'package:tarjuman/features/transcript/presentation/cubit/transcript_cubit.dart';
import 'package:tarjuman/features/vocabulary/data/mlkit_word_translator.dart';
import 'package:tarjuman/features/vocabulary/data/vocabulary_repository_impl.dart';
import 'package:tarjuman/features/vocabulary/domain/ports/word_translator.dart';
import 'package:tarjuman/features/vocabulary/domain/repositories/vocabulary_repository.dart';
import 'package:tarjuman/features/vocabulary/domain/services/spaced_repetition.dart';
import 'package:tarjuman/features/vocabulary/domain/usecases/backup_vocabulary.dart';
import 'package:tarjuman/features/vocabulary/domain/usecases/export_vocabulary.dart';
import 'package:tarjuman/features/vocabulary/presentation/cubit/review_cubit.dart';
import 'package:tarjuman/features/vocabulary/presentation/cubit/study_cubit.dart';
import 'package:tarjuman/features/vocabulary/presentation/cubit/vocabulary_cubit.dart';

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
    ..registerLazySingleton<BrightnessControl>(ScreenBrightnessControl.new)
    ..registerLazySingleton<VocabularyRepository>(
      () => VocabularyRepositoryImpl(sl()),
    )
    ..registerLazySingleton<WordTranslator>(() => MlKitWordTranslator(sl()))
    ..registerLazySingleton<GlossaryRepository>(
      () => GlossaryRepositoryImpl(sl()),
    )
    ..registerLazySingleton<GoRouter>(() => buildRouter(sl()))
    ..registerSingleton<GlobalKey<ScaffoldMessengerState>>(
      GlobalKey<ScaffoldMessengerState>(),
    )
    ..registerSingleton<IncomingMediaSource>(
      MethodChannelIncomingMediaSource(),
    )
    ..registerFactory(() => ImportSharedMedia(sl(), sl()))
    ..registerLazySingleton<AppNotifier>(LocalAppNotifier.new)
    ..registerLazySingleton(() => DownloadsSystemBridge(sl(), sl(), sl()))
    ..registerLazySingleton(() => IncomingMediaHandler(sl(), sl()))
    ..registerLazySingleton<BackgroundProcessing>(
      ForegroundTaskBackgroundProcessing.new,
    )
    ..registerFactory(() => OnboardingCubit(sl(), sl()))
    ..registerLazySingleton<StorageInspector>(FileStorageInspector.new)
    ..registerFactory(() => StorageCubit(sl(), sl(), sl()))
    ..registerLazySingleton<Pronouncer>(FlutterTtsPronouncer.new)
    ..registerLazySingleton(() => const SpacedRepetition())
    ..registerFactory(() => ReviewCubit(sl(), sl()))
    ..registerFactory(() => ExportVocabulary(sl(), sl()))
    ..registerFactory(() => BackupVocabulary(sl(), sl()))
    ..registerFactory(() => RestoreVocabulary(sl(), sl()))
    ..registerFactory(() => StudyCubit(sl(), sl()))
    ..registerFactory(() => VocabularyCubit(sl()))
    ..registerLazySingleton<FileDownloader>(HttpFileDownloader.new)
    ..registerLazySingleton<LinkResolver>(CompositeLinkResolver.new)
    ..registerLazySingleton<MediaExporter>(PlatformMediaExporter.new)
    ..registerFactory(() => ExportVideoFile(sl(), sl()))
    ..registerLazySingleton(() => DownloadsCubit(sl(), sl(), sl()))
    ..registerFactory(() => ImportFromUrl(sl(), sl(), sl(), sl()))
    ..registerFactory(() => ToggleFavorite(sl()))
    ..registerFactory(() => SearchSubtitles(sl()))
    ..registerFactory(() => LibraryCubit(sl(), sl(), sl(), sl(), sl()))
    ..registerLazySingleton(() => const SubtitleSerializer())
    ..registerLazySingleton<SubtitleExporter>(SharePlusSubtitleExporter.new)
    ..registerFactory(() => ExportTranscript(sl(), sl(), sl()))
    ..registerFactory(() => EditCueText(sl()))
    ..registerFactory(() => RetranslateCue(sl(), sl()))
    ..registerFactory(() => ExportSubtitles(sl(), sl(), sl(), sl()))
    ..registerSingleton<SecretStore>(const KeystoreSecretStore())
    ..registerLazySingleton<OnlineConfig>(
      () => SettingsOnlineConfig(sl(), sl()),
    )
    ..registerLazySingleton(() => OnlineEngines(sl()))
    ..registerLazySingleton<DeviceCapability>(DeviceInfoCapability.new)
    ..registerLazySingleton<ModelRepository>(() => ModelRepositoryImpl(sl()))
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
    ..registerLazySingleton<LanguageDetector>(
      () => WhisperLanguageDetector(sl()),
    )
    ..registerFactory(() => DetectLanguage(sl(), sl(), _workPath))
    ..registerFactory(() => SetupCubit(sl(), sl(), sl(), sl(), sl()))
    ..registerSingleton<AppSettingsCubit>(
      AppSettingsCubit(sl(), sl()),
    );
}

Future<String> _workPath(String name) async {
  final dir = Directory(p.join((await getTemporaryDirectory()).path, 'work'));
  await dir.create(recursive: true);
  return p.join(dir.path, name);
}

ProcessingCubit newProcessingCubit(
  String videoId,
  EngineKind kind,
  SourceLanguage language, {
  required String notificationTitle,
  required String Function(int percent) notificationText,
}) => ProcessingCubit(
  videoId: videoId,
  kind: kind,
  language: language,
  pipeline: sl(),
  background: sl(),
  notificationTitle: notificationTitle,
  notificationText: notificationText,
);

/// Player cubits are per-video and own a fresh engine.
PlayerCubit newPlayerCubit(
  String videoId, {
  EngineKind? liveKind,
  SourceLanguage language = SourceLanguage.en,
  bool follow = false,
  Duration? startAt,
}) => PlayerCubit(
  videoId: videoId,
  videos: sl(),
  startAt: startAt,
  engine: MediaKitEngine(),
  brightness: sl(),
  load: sl(),
  attach: sl(),
  settings: sl(),
  engines: sl(),
  liveFactory: sl.call<LiveSubtitleSession>,
  liveKind: liveKind,
  liveLanguage: language,
  followProcessing: follow,
);

TranscriptCubit newTranscriptCubit(String videoId) => TranscriptCubit(
  videoId: videoId,
  subtitles: sl(),
  serializer: sl(),
  export: sl(),
);

EditorCubit newEditorCubit(String videoId) => EditorCubit(
  videoId: videoId,
  subtitles: sl(),
  edit: sl(),
  export: sl(),
  retranslate: sl(),
  language: SourceLanguage.fromCode(sl<SettingsStore>().readSourceLanguage()),
);
