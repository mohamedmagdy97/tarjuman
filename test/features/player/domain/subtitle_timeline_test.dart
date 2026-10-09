import 'package:flutter_test/flutter_test.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_timeline.dart';

SubtitleCue cue(int s, int e, String t, [CueStatus st = CueStatus.committed]) =>
    SubtitleCue(
      start: Duration(seconds: s),
      end: Duration(seconds: e),
      text: t,
      status: st,
    );

void main() {
  final timeline = SubtitleTimeline([
    cue(10, 14, 'b'),
    cue(0, 4, 'a'),
    cue(20, 25, 'c'),
  ]);

  test('returns active cue inside its range', () {
    expect(timeline.activeAt(const Duration(seconds: 2))?.text, 'a');
    expect(timeline.activeAt(const Duration(seconds: 12))?.text, 'b');
  });

  test('end is exclusive and gaps return null', () {
    expect(timeline.activeAt(const Duration(seconds: 4)), isNull);
    expect(timeline.activeAt(const Duration(seconds: 15)), isNull);
  });

  test('before first and after last cue return null', () {
    expect(timeline.activeAt(const Duration(seconds: 30)), isNull);
    expect(const SubtitleTimeline.empty().activeAt(Duration.zero), isNull);
  });

  test('seeking backwards finds earlier cue', () {
    expect(timeline.activeAt(const Duration(seconds: 22))?.text, 'c');
    expect(timeline.activeAt(const Duration(seconds: 1))?.text, 'a');
  });

  test('upsert replaces partial cue with committed one at same start', () {
    final live = SubtitleTimeline([
      cue(0, 4, 'hel', CueStatus.partial),
    ]).upsert(cue(0, 4, 'hello'));
    expect(live.cues, hasLength(1));
    expect(live.cues.single.text, 'hello');
    expect(live.cues.single.status, CueStatus.committed);
  });
}
