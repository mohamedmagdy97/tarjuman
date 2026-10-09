import 'package:go_router/go_router.dart';
import 'package:tarjuman/features/library/presentation/pages/library_page.dart';
import 'package:tarjuman/features/model_manager/presentation/pages/models_page.dart';
import 'package:tarjuman/features/player/presentation/pages/player_page.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/presentation/pages/processing_page.dart';
import 'package:tarjuman/features/processing/presentation/pages/setup_page.dart';
import 'package:tarjuman/features/settings/presentation/pages/settings_page.dart';

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
      ),
    ),
    GoRoute(path: '/models', builder: (_, _) => const ModelsPage()),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
  ],
);
