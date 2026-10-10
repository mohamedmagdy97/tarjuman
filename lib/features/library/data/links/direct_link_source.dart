import 'package:http/http.dart' as http;
import 'package:tarjuman/features/library/data/links/link_exceptions.dart';
import 'package:tarjuman/features/library/domain/ports/link_source.dart';

/// A plain HTTP file. The response is opened lazily, so a resolver can hand
/// back the already-sent request without buffering anything.
class DirectLinkSource implements LinkSource {
  DirectLinkSource({
    required this.url,
    required this.title,
    required this.extension,
    this.headers = const {},
  });

  final Uri url;
  final Map<String, String> headers;
  @override
  final String title;
  @override
  final String extension;

  @override
  Stream<List<int>> open(void Function(double? fraction) onProgress) async* {
    final client = http.Client();
    try {
      final res = await client.send(
        http.Request('GET', url)..headers.addAll(headers),
      );
      if (res.statusCode != 200) {
        throw HttpStatusException(res.statusCode, url);
      }
      final total = res.contentLength;
      var received = 0;
      await for (final chunk in res.stream) {
        received += chunk.length;
        onProgress(total == null || total == 0 ? null : received / total);
        yield chunk;
      }
    } finally {
      client.close();
    }
  }
}
