import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarjuman/features/browser/domain/media_url_filter.dart';
import 'package:tarjuman/features/browser/presentation/cubit/browser_cubit.dart';
import 'package:tarjuman/features/library/domain/link_normalizer.dart';

void main() {
  group('MediaUrlFilter', () {
    test('accepts video files and manifests, rejects fragments and pages', () {
      expect(MediaUrlFilter.looksLikeVideo('https://c.x/a/v.mp4?t=1'), isTrue);
      expect(MediaUrlFilter.looksLikeVideo('https://c.x/live.m3u8'), isTrue);
      expect(
        MediaUrlFilter.looksLikeVideo('https://c.x/g?mime=video%2Fmp4'),
        isTrue,
      );
      expect(MediaUrlFilter.looksLikeVideo('https://c.x/seg1.ts'), isFalse);
      expect(MediaUrlFilter.looksLikeVideo('https://c.x/seg.m4s'), isFalse);
      expect(MediaUrlFilter.looksLikeVideo('https://c.x/index.html'), isFalse);
      expect(MediaUrlFilter.looksLikeVideo('blob:https://c.x/1'), isFalse);
    });
  });

  group('BrowserCubit', () {
    blocTest<BrowserCubit, BrowserState>(
      'collects media once per file and clears on navigation',
      build: BrowserCubit.new,
      act: (c) => c
        ..found('https://c.x/v.mp4?range=0-100')
        ..found('https://c.x/v.mp4?range=100-200')
        ..found('https://c.x/page.html')
        ..found('https://c.x/other.webm')
        ..navigated('https://c.x/next'),
      verify: (c) => expect(c.state.detected, isEmpty),
      expect: () => [
        isA<BrowserState>().having((s) => s.detected.length, 'n', 1),
        isA<BrowserState>().having((s) => s.detected.length, 'n', 2),
        isA<BrowserState>().having((s) => s.detected.length, 'n', 0),
      ],
    );
  });

  group('normalizeUrl', () {
    test('accepts bare domains and pasted sentences', () {
      expect(
        normalizeUrl('www.facebook.com/watch?v=1').toString(),
        'https://www.facebook.com/watch?v=1',
      );
      expect(
        normalizeUrl('look at this https://youtu.be/abc now').toString(),
        'https://youtu.be/abc',
      );
      expect(normalizeUrl('  https://a.b/c  ').toString(), 'https://a.b/c');
    });

    test('rejects text that is not an address', () {
      expect(normalizeUrl(''), isNull);
      expect(normalizeUrl('hello world'), isNull);
      expect(normalizeUrl('localhost'), isNull);
    });
  });
}
