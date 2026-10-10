import 'package:tarjuman/features/library/domain/ports/link_source.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// YouTube watch/short/shorts/youtu.be links via `youtube_explode_dart`.
/// Muxed streams only (audio + video in one file, up to 360p/720p).
class YoutubeLinkResolver {
  static bool handles(Uri url) {
    final h = url.host.toLowerCase();
    return h == 'youtu.be' || h == 'youtube.com' || h.endsWith('.youtube.com');
  }

  Future<LinkSource> resolve(Uri url) async {
    final yt = YoutubeExplode();
    try {
      final video = await yt.videos.get(url.toString());
      final manifest = await yt.videos.streams.getManifest(video.id);
      final stream = manifest.muxed.bestQuality;
      return _YoutubeSource(yt, stream, video.title);
    } on Object {
      yt.close();
      rethrow;
    }
  }
}

class _YoutubeSource implements LinkSource {
  _YoutubeSource(this._yt, this._stream, this.title);
  final YoutubeExplode _yt;
  final StreamInfo _stream;
  @override
  final String title;

  @override
  String get extension => _stream.container.name;

  @override
  Stream<List<int>> open(void Function(double? fraction) onProgress) async* {
    final total = _stream.size.totalBytes;
    var received = 0.0;
    try {
      await for (final chunk in _yt.videos.streams.get(_stream)) {
        received += chunk.length;
        onProgress(total == 0 ? null : received / total);
        yield chunk;
      }
    } finally {
      _yt.close();
    }
  }
}
