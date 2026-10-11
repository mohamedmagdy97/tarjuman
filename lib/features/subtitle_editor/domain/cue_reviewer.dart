import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';

enum CueIssue {
  untranslated,
  leftoverLatin,
  tooShort,
  tooLong,
  readsTooFast,
  repeated,
}

/// Heuristics that flag lines worth a second look. They use only what is
/// stored with each cue, so they work on every existing video. Lines the
/// user already edited are considered reviewed.
class CueReviewer {
  const CueReviewer();

  static final _latin = RegExp('[A-Za-z]');
  static final _arabic = RegExp('[؀-ۿ]');

  /// Issues per cue, in the same order as [cues].
  List<Set<CueIssue>> review(List<SubtitleCue> cues) => [
    for (var i = 0; i < cues.length; i++)
      cues[i].status == CueStatus.edited
          ? const {}
          : _issues(cues[i], i > 0 ? cues[i - 1] : null),
  ];

  Set<CueIssue> _issues(SubtitleCue cue, SubtitleCue? previous) {
    final out = <CueIssue>{};
    final text = cue.text.trim();
    final source = cue.original?.trim() ?? '';

    if (source.isNotEmpty && _same(text, source)) {
      out.add(CueIssue.untranslated);
    } else if (_latinShare(text) > .5 && text.length >= 6) {
      out.add(CueIssue.leftoverLatin);
    }

    if (source.length >= 20 && text.length < source.length * .25) {
      out.add(CueIssue.tooShort);
    }
    if (source.isNotEmpty && text.length > source.length * 3.5) {
      out.add(CueIssue.tooLong);
    }

    final seconds = (cue.end - cue.start).inMilliseconds / 1000;
    if (seconds > 0 && text.length / seconds > 25) {
      out.add(CueIssue.readsTooFast);
    }

    if (previous != null && _same(previous.text, text) && text.isNotEmpty) {
      out.add(CueIssue.repeated);
    }
    return out;
  }

  bool _same(String a, String b) =>
      a.toLowerCase().replaceAll(RegExp(r'\s+'), ' ') ==
      b.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  double _latinShare(String s) {
    final latin = _latin.allMatches(s).length;
    final arabic = _arabic.allMatches(s).length;
    final letters = latin + arabic;
    return letters == 0 ? 0 : latin / letters;
  }
}
