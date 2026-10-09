import 'package:go_router/go_router.dart';
import 'package:tarjuman/features/library/presentation/pages/library_page.dart';
import 'package:tarjuman/features/player/presentation/pages/player_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, _) => const LibraryPage()),
    GoRoute(
      path: '/player/:id',
      builder: (_, state) => PlayerPage(videoId: state.pathParameters['id']!),
    ),
  ],
);
