import 'package:http/http.dart' as http;
import 'package:tarjuman/features/library/data/links/link_exceptions.dart';
import 'package:tarjuman/features/library/domain/ports/link_source.dart';

/// Downloads an unencrypted HLS playlist by concatenating its segments
/// (MPEG-TS, or fMP4 when the playlist has an init segment). Encrypted
/// playlists are rejected: that is DRM-like and out of scope.
class HlsLinkSource implements LinkSource {
  HlsLinkSource({
    required this.playlist,
    required this.title,
    this.headers = const {},
  });

  final Uri playlist;
  final Map<String, String> headers;
  @override
  final String title;
  bool _fragmented = false;

  @override
  String get extension => _fragmented ? 'mp4' : 'ts';

  @override
  Stream<List<int>> open(void Function(double? fraction) onProgress) async* {
    final client = http.Client();
    try {
      var media = playlist;
      var text = await _text(client, media);
      if (text.contains('#EXT-X-STREAM-INF')) {
        media = _bestVariant(text, media);
        text = await _text(client, media);
      }
      if (text.contains('#EXT-X-KEY') && !text.contains('METHOD=NONE')) {
        throw const FormatException('Encrypted stream');
      }
      final map = RegExp('#EXT-X-MAP:.*URI="([^"]+)"').firstMatch(text);
      _fragmented = map != null;
      final segments = [
        if (map != null) media.resolve(map.group(1)!),
        for (final l in text.split('\n'))
          if (l.trim().isNotEmpty && !l.startsWith('#'))
            media.resolve(l.trim()),
      ];
      for (var i = 0; i < segments.length; i++) {
        final res = await client.get(segments[i], headers: headers);
        if (res.statusCode != 200) {
          throw HttpStatusException(res.statusCode, segments[i]);
        }
        yield res.bodyBytes;
        onProgress((i + 1) / segments.length);
      }
    } finally {
      client.close();
    }
  }

  Future<String> _text(http.Client c, Uri url) async {
    final res = await c.get(url, headers: headers);
    if (res.statusCode != 200) {
      throw HttpStatusException(res.statusCode, url);
    }
    return res.body;
  }

  /// Highest bandwidth variant at or below 720p (falls back to the best).
  static Uri _bestVariant(String master, Uri base) {
    final lines = master.split('\n');
    Uri? best;
    var bestScore = -1;
    for (var i = 0; i < lines.length - 1; i++) {
      if (!lines[i].startsWith('#EXT-X-STREAM-INF')) continue;
      final bw =
          int.tryParse(
            RegExp(r'BANDWIDTH=(\d+)').firstMatch(lines[i])?.group(1) ?? '',
          ) ??
          0;
      final h =
          int.tryParse(
            RegExp(r'RESOLUTION=\d+x(\d+)').firstMatch(lines[i])?.group(1) ??
                '',
          ) ??
          0;
      final score = (h <= 720 ? 1 << 40 : 0) + bw;
      if (score > bestScore) {
        bestScore = score;
        best = base.resolve(lines[i + 1].trim());
      }
    }
    return best ?? base;
  }
}
