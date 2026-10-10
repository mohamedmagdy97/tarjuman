/// Decides which URLs seen by the in-app browser are downloadable videos.
class MediaUrlFilter {
  const MediaUrlFilter._();

  static const _extensions = {
    'mp4',
    'm4v',
    'webm',
    'mov',
    'mkv',
    'avi',
    'flv',
    '3gp',
    'ts',
    'm3u8',
    'mp3',
    'm4a',
    'aac',
    'ogg',
    'wav',
  };

  /// HLS/DASH fragments and tracking pixels are noise.
  static const _fragments = {'ts', 'm4s'};

  static bool looksLikeVideo(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      return false;
    }
    final path = uri.path.toLowerCase();
    final dot = path.lastIndexOf('.');
    final ext = dot < 0 ? '' : path.substring(dot + 1);
    if (_fragments.contains(ext)) return false;
    if (_extensions.contains(ext)) return true;
    final mime =
        uri.queryParameters['mime'] ?? uri.queryParameters['mime_type'];
    return mime != null &&
        (mime.startsWith('video') || mime.startsWith('audio'));
  }

  /// Same file requested with different range/token params counts once.
  static String dedupeKey(String url) {
    final uri = Uri.parse(url);
    return '${uri.host}${uri.path}';
  }
}
