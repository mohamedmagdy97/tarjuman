import 'package:flutter_test/flutter_test.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';
import 'package:tarjuman/features/subtitle_editor/domain/cue_reviewer.dart';

SubtitleCue cue(
  String text, {
  String? original,
  int startSec = 0,
  int lengthSec = 4,
  CueStatus status = CueStatus.committed,
}) => SubtitleCue(
  start: Duration(seconds: startSec),
  end: Duration(seconds: startSec + lengthSec),
  text: text,
  original: original,
  status: status,
);

void main() {
  const reviewer = CueReviewer();

  Set<CueIssue> one(SubtitleCue c) => reviewer.review([c]).single;

  test('a healthy line has no issues', () {
    expect(
      one(cue('مرحبا بكم في هذا الدرس', original: 'Welcome to this lesson')),
      isEmpty,
    );
  });

  test('flags untranslated and mostly-Latin lines', () {
    expect(
      one(cue('Hello there', original: 'hello  there')),
      contains(CueIssue.untranslated),
    );
    expect(
      one(cue('this is still english', original: 'x')),
      contains(CueIssue.leftoverLatin),
    );
  });

  test('flags a translation far shorter or longer than the source', () {
    expect(
      one(
        cue('نعم', original: 'Well, I think we should talk about it tomorrow'),
      ),
      contains(CueIssue.tooShort),
    );
    expect(
      one(cue('كلام ' * 30, original: 'Yes')),
      contains(CueIssue.tooLong),
    );
  });

  test('flags text that cannot be read in the time available', () {
    expect(
      one(cue('ا' * 120, original: 'x' * 100, lengthSec: 2)),
      contains(CueIssue.readsTooFast),
    );
  });

  test('flags a line repeated from the previous cue', () {
    final issues = reviewer.review([
      cue('جملة مكررة', original: 'Same'),
      cue('جملة مكررة', original: 'Same', startSec: 5),
    ]);
    expect(issues[0], isNot(contains(CueIssue.repeated)));
    expect(issues[1], contains(CueIssue.repeated));
  });

  test('edited lines are treated as already reviewed', () {
    expect(
      one(cue('Hello', original: 'Hello', status: CueStatus.edited)),
      isEmpty,
    );
  });
}
