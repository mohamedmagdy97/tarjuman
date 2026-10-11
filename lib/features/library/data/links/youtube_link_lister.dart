import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/data/links/youtube_link_resolver.dart';
import 'package:tarjuman/features/library/domain/ports/link_lister.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// YouTube playlists (`?list=`) and channels (`/@handle`, `/channel/ID`,
/// `/user/NAME`) via `youtube_explode_dart`.
class YoutubeLinkLister implements LinkLister {
  @override
  bool supports(Uri url) =>
      YoutubeLinkResolver.handles(url) &&
      (_playlistId(url) != null || _channelKind(url) != null);

  String? _playlistId(Uri url) {
    final id = url.queryParameters['list'];
    // "RD…" mixes are endless auto-playlists; skip them.
    return id == null || id.isEmpty || id.startsWith('RD') ? null : id;
  }

  ({String kind, String value})? _channelKind(Uri url) {
    final s = url.pathSegments;
    if (s.isEmpty) return null;
    if (s.first.startsWith('@')) return (kind: 'handle', value: s.first);
    if (s.length >= 2 && s.first == 'channel') {
      return (kind: 'id', value: s[1]);
    }
    if (s.length >= 2 && s.first == 'user') {
      return (kind: 'user', value: s[1]);
    }
    return null;
  }

  @override
  Future<Result<LinkListing>> list(Uri url, {int limit = 50}) async {
    final yt = YoutubeExplode();
    try {
      final listId = _playlistId(url);
      if (listId != null) {
        final playlist = await yt.playlists.get(listId);
        final videos = await yt.playlists
            .getVideos(listId)
            .take(limit)
            .toList();
        return Result.success(_listing(playlist.title, videos));
      }
      final ch = _channelKind(url);
      if (ch == null) return const Result.failure(NoVideoFoundFailure());
      final channel = switch (ch.kind) {
        'handle' => await yt.channels.getByHandle(ch.value),
        'user' => await yt.channels.getByUsername(ch.value),
        _ => await yt.channels.get(ch.value),
      };
      final videos = await yt.channels
          .getUploads(channel.id)
          .take(limit)
          .toList();
      return Result.success(_listing(channel.title, videos));
    } on Object catch (e) {
      return Result.failure(
        NoVideoFoundFailure('YouTube: ${e.toString().split('\n').first}'),
      );
    } finally {
      yt.close();
    }
  }

  LinkListing _listing(String title, List<Video> videos) => LinkListing(
    title: title,
    entries: [
      for (final v in videos)
        ListedLink(
          title: v.title,
          url: 'https://www.youtube.com/watch?v=${v.id.value}',
        ),
    ],
  );
}
