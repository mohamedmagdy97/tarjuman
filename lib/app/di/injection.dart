import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarjuman/core/database/app_database.dart';
import 'package:tarjuman/core/platform/media/video_player_engine.dart';
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
import 'package:tarjuman/features/player/data/subtitle_repository_impl.dart';
import 'package:tarjuman/features/player/domain/repositories/subtitle_repository.dart';
import 'package:tarjuman/features/player/domain/services/subtitle_parser.dart';
import 'package:tarjuman/features/player/domain/usecases/attach_subtitles.dart';
import 'package:tarjuman/features/player/domain/usecases/load_player_data.dart';
import 'package:tarjuman/features/player/presentation/cubit/player_cubit.dart';

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
    ..registerFactory(() => ImportVideo(sl(), sl()))
    ..registerFactory(() => DeleteVideo(sl()))
    ..registerFactory(() => LoadPlayerData(sl(), sl()))
    ..registerFactory(() => AttachSubtitles(sl(), sl(), sl()))
    ..registerFactory(() => LibraryCubit(sl(), sl(), sl()));
}

/// Player cubits are per-video and own a fresh engine.
PlayerCubit newPlayerCubit(String videoId) => PlayerCubit(
  videoId: videoId,
  engine: VideoPlayerEngine(),
  load: sl(),
  attach: sl(),
  settings: sl(),
);
