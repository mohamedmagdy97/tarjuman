import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/data/links/direct_link_source.dart';
import 'package:tarjuman/features/library/data/links/hls_link_source.dart';
import 'package:tarjuman/features/library/domain/ports/link_source.dart';

/// Direct file links, and web pages: the page is fetched and a video URL is
/// looked for in Open Graph tags, `<video>`/`<source>`, JSON-LD and the
/// player config Facebook embeds in public posts.
class PageLinkResolver {
  PageLinkResolver({http.Client Function()? client})
    : _client = client ?? http.Client.new;
  final http.Client Function() _client;

  static const _ua =
      'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/124.0 Mobile Safari/537.36';
  Failure _statusFailure(int status) => switch (status) {
    404 || 410 => NoVideoFoundFailure('HTTP $status'),
    >= 500 => NetworkFailure('HTTP $status'),
    _ => SiteRefusedFailure('HTTP $status'),
  };

  static const _headers = {
    'User-Agent': _ua,
    'Accept-Language': 'en-US,en;q=0.9',
  };

  Future<Result<LinkSource>> resolve(Uri url, {String? referer}) async {
    final client = _client();
    try {
      final res = await client.send(
        http.Request('GET', url)
          ..headers.addAll({..._headers, 'Referer': ?referer}),
      );
      if (res.statusCode != 200) {
        return Result.failure(_statusFailure(res.statusCode));
      }
      final type = (res.headers['content-type'] ?? '').toLowerCase();
      if (!type.contains('text/html') && !type.contains('xhtml')) {
        res.stream.listen(null).cancel().ignore();
        return Result.success(
          _forUrl(url, _nameFrom(url), type: type, referer: referer),
        );
      }
      final html = await res.stream
          .transform(utf8.decoder)
          .take(4)
          .join()
          .timeout(const Duration(seconds: 20), onTimeout: () => '');
      return _fromHtml(url, html, client);
    } on SocketException catch (e) {
      return Result.failure(
        NetworkFailure(e.message.isEmpty ? 'No connection' : e.message),
      );
    } on HandshakeException {
      return const Result.failure(NetworkFailure('Secure connection failed'));
    } on TimeoutException {
      return const Result.failure(NetworkFailure('Timed out'));
    } on http.ClientException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } finally {
      client.close();
    }
  }

  Future<Result<LinkSource>> _fromHtml(
    Uri page,
    String html,
    http.Client client,
  ) async {
    final found = extractVideoUrl(html);
    if (found == null) {
      return const Result.failure(NoVideoFoundFailure());
    }
    final media = page.resolve(found);
    return Result.success(
      _forUrl(
        media,
        extractTitle(html) ?? _nameFrom(page),
        referer: page.toString(),
      ),
    );
  }

  LinkSource _forUrl(
    Uri url,
    String title, {
    String type = '',
    String? referer,
  }) {
    final headers = {..._headers, 'Referer': ?referer};
    final isHls =
        type.contains('mpegurl') || url.path.toLowerCase().endsWith('.m3u8');
    if (isHls) {
      return HlsLinkSource(playlist: url, title: title, headers: headers);
    }
    final ext =
        url.pathSegments.isNotEmpty && url.pathSegments.last.contains('.')
        ? url.pathSegments.last.split('.').last.toLowerCase()
        : 'mp4';
    return DirectLinkSource(
      url: url,
      title: title,
      extension: ext.length > 5 ? 'mp4' : ext,
      headers: headers,
    );
  }

  String _nameFrom(Uri url) => url.pathSegments.isNotEmpty
      ? Uri.decodeComponent(url.pathSegments.last)
      : url.host;

  static String _unescape(String s) => s
      .replaceAll(r'\/', '/')
      .replaceAll('%', '%')
      .replaceAll('&', '&')
      .replaceAll('&amp;', '&');

  /// Best video URL in [html], or null. Visible for tests.
  static String? extractVideoUrl(String html) {
    const patterns = [
      // Facebook public videos (HD first).
      r'"(?:browser_native_hd_url|playable_url_quality_hd|hd_src)"\s*:\s*"([^"]+)"',
      r'"(?:browser_native_sd_url|playable_url|sd_src)"\s*:\s*"([^"]+)"',
      // Open Graph / Twitter cards.
      r'<meta[^>]+property=["\x27]og:video(?::secure_url|:url)?["\x27][^>]+content=["\x27]([^"\x27]+)',
      r'<meta[^>]+content=["\x27]([^"\x27]+)["\x27][^>]+property=["\x27]og:video(?::secure_url|:url)?["\x27]',
      r'<meta[^>]+name=["\x27]twitter:player:stream["\x27][^>]+content=["\x27]([^"\x27]+)',
      // JSON-LD VideoObject.
      r'"contentUrl"\s*:\s*"([^"]+)"',
      // Plain HTML5 video.
      r'<video[^>]+src=["\x27]([^"\x27]+)',
      r'<source[^>]+src=["\x27]([^"\x27]+(?:mp4|m3u8|webm)[^"\x27]*)',
      // Any manifest/file URL embedded in the page scripts.
      r'"(https?:[^"\s]+?\.m3u8[^"\s]*)"',
      r'"(https?:[^"\s]+?\.mp4[^"\s]*)"',
    ];
    for (final p in patterns) {
      final m = RegExp(p, caseSensitive: false).firstMatch(html);
      final url = m?.group(1);
      if (url != null && url.isNotEmpty && !url.startsWith('blob:')) {
        return _unescape(url);
      }
    }
    return null;
  }

  static String? extractTitle(String html) {
    final og = RegExp(
      r'<meta[^>]+property=["\x27]og:title["\x27][^>]+content=["\x27]([^"\x27]+)',
      caseSensitive: false,
    ).firstMatch(html)?.group(1);
    final t =
        og ??
        RegExp(
          '<title[^>]*>([^<]+)</title>',
          caseSensitive: false,
        ).firstMatch(html)?.group(1);
    final clean = t?.replaceAll('&amp;', '&').replaceAll('&#039;', "'").trim();
    return clean == null || clean.isEmpty ? null : clean;
  }
}
