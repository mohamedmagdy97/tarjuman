import 'package:go_router/go_router.dart';
import 'package:tarjuman/core/settings/settings_store.dart';
import 'package:tarjuman/features/glossary/presentation/pages/glossary_page.dart';
import 'package:tarjuman/features/library/presentation/pages/library_page.dart';
import 'package:tarjuman/features/model_manager/presentation/pages/models_page.dart';
import 'package:tarjuman/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:tarjuman/features/player/presentation/pages/player_page.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/presentation/pages/processing_page.dart';
import 'package:tarjuman/features/processing/presentation/pages/setup_page.dart';
import 'package:tarjuman/features/settings/presentation/pages/settings_page.dart';
import 'package:tarjuman/features/storage/presentation/pages/storage_page.dart';
import 'package:tarjuman/features/subtitle_editor/presentation/pages/editor_page.dart';
import 'package:tarjuman/features/transcript/presentation/pages/transcript_page.dart';
import 'package:tarjuman/features/vocabulary/presentation/pages/review_page.dart';
import 'package:tarjuman/features/vocabulary/presentation/pages/vocabulary_page.dart';

EngineKind? _kind(String? raw) => EngineKind.values.asNameMap()[raw];

/// First launch shows the welcome flow once.
GoRouter buildRouter(SettingsStore settings) => GoRouter(
  redirect: (context, state) {
    if (state.matchedLocation == '/' && !settings.readOnboardingDone()) {
      return '/onboarding';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingPage()),
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
        language: SourceLanguage.fromCode(s.uri.queryParameters['lang']),
      ),
    ),
    GoRoute(
      path: '/player/:id',
      builder: (_, s) => PlayerPage(
        videoId: s.pathParameters['id']!,
        liveKind: _kind(s.uri.queryParameters['live']),
        language: SourceLanguage.fromCode(s.uri.queryParameters['lang']),
        startAtMs: int.tryParse(s.uri.queryParameters['t'] ?? ''),
        follow: s.uri.queryParameters['follow'] == '1',
      ),
    ),
    GoRoute(
      path: '/editor/:id',
      builder: (_, s) => EditorPage(videoId: s.pathParameters['id']!),
    ),
    GoRoute(path: '/vocabulary', builder: (_, _) => const VocabularyPage()),
    GoRoute(path: '/review', builder: (_, _) => const ReviewPage()),
    GoRoute(
      path: '/transcript/:id',
      builder: (_, s) => TranscriptPage(videoId: s.pathParameters['id']!),
    ),
    GoRoute(path: '/storage', builder: (_, _) => const StoragePage()),
    GoRoute(path: '/glossary', builder: (_, _) => const GlossaryPage()),
    GoRoute(path: '/models', builder: (_, _) => const ModelsPage()),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
  ],
);
