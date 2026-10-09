import 'package:flutter_test/flutter_test.dart';
import 'package:tarjuman/features/processing/domain/entities/transcript_segment.dart';
import 'package:tarjuman/features/processing/domain/services/cue_segmenter.dart';

TranscriptSegment seg(int startMs, int endMs, String t) => TranscriptSegment(
  start: Duration(milliseconds: startMs),
  end: Duration(milliseconds: endMs),
  text: t,
);

void main() {
  const segmenter = CueSegmenter();

  test('merges short fragments of one sentence', () {
    final out = segmenter.merge([
      seg(0, 1000, 'We will'),
      seg(1100, 2200, 'change how we learn.'),
    ]);
    expect(out, hasLength(1));
    expect(out.single.text, 'We will change how we learn.');
    expect(out.single.end, const Duration(milliseconds: 2200));
  });

  test('does not merge across a sentence end or a long gap', () {
    final out = segmenter.merge([
      seg(0, 1000, 'Hello there.'),
      seg(1100, 2000, 'Next one'),
      seg(5000, 6000, 'after a gap'),
    ]);
    expect(out.map((s) => s.text), ['Hello there.', 'Next one', 'after a gap']);
  });

  test('drops sound tags and blank text', () {
    final out = segmenter.merge([
      seg(0, 1000, '[MUSIC]'),
      seg(1000, 2000, '  '),
      seg(2000, 3000, 'Hi'),
    ]);
    expect(out.map((s) => s.text), ['Hi']);
  });

  test('does not exceed max duration or chars when merging', () {
    final out = segmenter.merge([
      seg(0, 4000, 'part one'),
      seg(4100, 8000, 'part two'),
    ]);
    expect(out, hasLength(2));
  });

  test('extends too-short cues and removes overlaps', () {
    final out = segmenter.merge([seg(0, 100, 'A.'), seg(300, 2000, 'B.')]);
    expect(out[0].end <= out[1].start, isTrue);
    expect(out[0].end - out[0].start > Duration.zero, isTrue);
  });
}
