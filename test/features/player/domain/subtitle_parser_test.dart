import 'package:flutter_test/flutter_test.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';
import 'package:tarjuman/features/player/domain/services/subtitle_parser.dart';

List<SubtitleCue> ok(String s) =>
    (const SubtitleParser().parse(s) as Success<List<SubtitleCue>>).value;

void main() {
  test('parses SRT with CRLF, BOM, ids and multi-line text', () {
    final cues = ok(
      '﻿1\r\n00:00:01,000 --> 00:00:03,500\r\nمرحبا\r\nبالعالم\r\n\r\n'
      '2\r\n00:01:00,250 --> 00:01:02,000\r\n<i>سطر</i> ثانٍ\r\n',
    );
    expect(cues, hasLength(2));
    expect(cues[0].start, const Duration(seconds: 1));
    expect(cues[0].end, const Duration(seconds: 3, milliseconds: 500));
    expect(cues[0].text, 'مرحبا\nبالعالم');
    expect(cues[1].start, const Duration(minutes: 1, milliseconds: 250));
    expect(cues[1].text, 'سطر ثانٍ');
  });

  test('parses WebVTT with header, NOTE, short timestamps and ids', () {
    final cues = ok(
      'WEBVTT\n\nNOTE comment\n\nintro\n00:01.500 --> 00:04.000 align:start\nHello\n',
    );
    expect(cues.single.start, const Duration(seconds: 1, milliseconds: 500));
    expect(cues.single.text, 'Hello');
  });

  test('fails on content without cues', () {
    expect(
      const SubtitleParser().parse('not a subtitle'),
      isA<Err<List<SubtitleCue>>>(),
    );
  });

  test('skips cues with non-positive duration or empty text', () {
    final cues = ok(
      '1\n00:00:05,000 --> 00:00:04,000\nbad\n\n2\n00:00:06,000 --> 00:00:07,000\nok\n',
    );
    expect(cues.map((c) => c.text), ['ok']);
  });
}
