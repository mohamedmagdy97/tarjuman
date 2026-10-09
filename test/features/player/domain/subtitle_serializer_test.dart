// SubtitleCue asserts end > start, which cannot be const-evaluated.
// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_timeline.dart';
import 'package:tarjuman/features/player/domain/services/subtitle_parser.dart';
import 'package:tarjuman/features/player/domain/services/subtitle_serializer.dart';

void main() {
  final timeline = SubtitleTimeline([
    SubtitleCue(
      start: Duration(hours: 1, minutes: 2, seconds: 3, milliseconds: 45),
      end: Duration(hours: 1, minutes: 2, seconds: 5),
      text: 'مرحبا',
      original: 'Hello',
    ),
    SubtitleCue(
      start: Duration(seconds: 1),
      end: Duration(seconds: 2, milliseconds: 500),
      text: 'أول سطر',
    ),
  ]);

  test('writes numbered SRT sorted by time with comma milliseconds', () {
    final srt = const SubtitleSerializer().toSrt(timeline);
    expect(srt, startsWith('1\n00:00:01,000 --> 00:00:02,500\nأول سطر\n\n2\n'));
    expect(srt, contains('01:02:03,045 --> 01:02:05,000\nمرحبا\n'));
    expect(srt, isNot(contains('Hello')));
  });

  test('can include the English original above the Arabic', () {
    final srt = const SubtitleSerializer().toSrt(
      timeline,
      includeOriginal: true,
    );
    expect(srt, contains('Hello\nمرحبا'));
  });

  test('output round-trips through the parser', () {
    final srt = const SubtitleSerializer().toSrt(timeline);
    final parsed =
        (const SubtitleParser().parse(srt) as Success<List<SubtitleCue>>).value;
    expect(parsed.map((c) => c.text), ['أول سطر', 'مرحبا']);
    expect(parsed.first.end, const Duration(seconds: 2, milliseconds: 500));
  });
}
