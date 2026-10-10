import 'package:go_router/go_router.dart';
import 'package:tarjuman/features/device_videos/presentation/pages/device_videos_page.dart';
import 'package:tarjuman/features/library/presentation/pages/library_page.dart';
import 'package:tarjuman/features/model_manager/presentation/pages/models_page.dart';
import 'package:tarjuman/features/player/presentation/pages/player_page.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/presentation/pages/processing_page.dart';
import 'package:tarjuman/features/processing/presentation/pages/setup_page.dart';
import 'package:tarjuman/features/settings/presentation/pages/settings_page.dart';
import 'package:tarjuman/features/subtitle_editor/presentation/pages/editor_page.dart';

EngineKind? _kind(String? raw) => EngineKind.values.asNameMap()[raw];

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, _) => const LibraryPage()),
    GoRoute(
      path: '/setup/:id',
      builder: (_, s) => SetupPage(videoId: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/processing/:id',
      builder: (_, s) => ProcessingPage(
        videoId: s.pathParameters['id']!,
        kind: _kind(s.uri.queryParameters['engine']) ?? EngineKind.offline,
      ),
    ),
    GoRoute(
      path: '/player/:id',
      builder: (_, s) => PlayerPage(
        videoId: s.pathParameters['id']!,
        liveKind: _kind(s.uri.queryParameters['live']),
        startAtMs: int.tryParse(s.uri.queryParameters['t'] ?? ''),
      ),
    ),
    GoRoute(
      path: '/editor/:id',
      builder: (_, s) => EditorPage(videoId: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/device-videos',
      builder: (_, _) => const DeviceVideosPage(),
    ),
    GoRoute(path: '/models', builder: (_, _) => const ModelsPage()),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
  ],
);
