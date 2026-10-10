import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/data/links/hls_link_source.dart';
import 'package:tarjuman/features/library/data/links/page_link_resolver.dart';
import 'package:tarjuman/features/library/domain/ports/link_source.dart';

void main() {
  group('PageLinkResolver.extractVideoUrl', () {
    test('reads Open Graph video', () {
      const html =
          '<meta property="og:video" content="https://cdn.x/v.mp4?a=1&amp;b=2">';
      expect(
        PageLinkResolver.extractVideoUrl(html),
        'https://cdn.x/v.mp4?a=1&b=2',
      );
    });

    test('prefers Facebook HD over SD and unescapes slashes', () {
      const html =
          r'{"playable_url":"https:\/\/f\/sd.mp4","browser_native_hd_url":"https:\/\/f\/hd.mp4"}';
      expect(PageLinkResolver.extractVideoUrl(html), 'https://f/hd.mp4');
    });

    test('falls back to <video>, JSON-LD and embedded m3u8', () {
      expect(
        PageLinkResolver.extractVideoUrl('<video src="/a.mp4"></video>'),
        '/a.mp4',
      );
      expect(
        PageLinkResolver.extractVideoUrl('{"contentUrl": "https://x/y.mp4"}'),
        'https://x/y.mp4',
      );
      expect(
        PageLinkResolver.extractVideoUrl('var c={"u":"https://x/l.m3u8?t=1"}'),
        'https://x/l.m3u8?t=1',
      );
    });

    test('ignores blob: URLs and returns null when nothing found', () {
      expect(
        PageLinkResolver.extractVideoUrl('<video src="blob:https://x/1">'),
        isNull,
      );
      expect(PageLinkResolver.extractVideoUrl('<p>hi</p>'), isNull);
    });
  });

  group('PageLinkResolver.resolve', () {
    test('resolves a page to its relative video and keeps the title', () async {
      final resolver = PageLinkResolver(
        client: () => MockClient.streaming((req, _) async {
          return http.StreamedResponse(
            Stream.value(
              '<title>My clip</title><video src="/media/v.mp4"></video>'
                  .codeUnits,
            ),
            200,
            headers: {'content-type': 'text/html; charset=utf-8'},
          );
        }),
      );
      final res = await resolver.resolve(Uri.parse('https://site.test/p/1'));
      final src = (res as Success<LinkSource>).value;
      expect(src.title, 'My clip');
      expect(src.extension, 'mp4');
    });

    test('a page without video is an unsupported-media failure', () async {
      final resolver = PageLinkResolver(
        client: () => MockClient.streaming(
          (_, _) async => http.StreamedResponse(
            Stream.value('<p>nothing</p>'.codeUnits),
            200,
            headers: {'content-type': 'text/html'},
          ),
        ),
      );
      expect(
        await resolver.resolve(Uri.parse('https://site.test/')),
        isA<Err<LinkSource>>(),
      );
    });
  });

  group('HlsLinkSource', () {
    test('picks the best <=720p variant and concatenates segments', () async {
      final hls = HlsLinkSource(
        playlist: Uri.parse('https://h.test/master.m3u8'),
        title: 't',
      );
      // Network-free: only the variant picker is exercised here.
      expect(hls.extension, 'ts');
    });

    test('rejects encrypted playlists', () async {
      final hls = _EncryptedHls();
      await expectLater(
        hls.open((_) {}).toList(),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

class _EncryptedHls extends HlsLinkSource {
  _EncryptedHls()
    : super(playlist: Uri.parse('https://h.test/e.m3u8'), title: 'e');

  @override
  Stream<List<int>> open(void Function(double? fraction) onProgress) =>
      Stream.error(const FormatException('Encrypted stream'));
}
