import 'package:tarjuman/features/processing/domain/entities/transcript_segment.dart';

/// Merges Whisper's fine-grained segments into readable subtitle units
/// (<= [maxChars], <= [maxDuration]) and repairs timing overlaps.
class CueSegmenter {
  const CueSegmenter({
    this.maxChars = 84,
    this.maxDuration = const Duration(seconds: 6),
    this.maxGap = const Duration(milliseconds: 500),
    this.minDuration = const Duration(milliseconds: 600),
  });

  final int maxChars;
  final Duration maxDuration;
  final Duration maxGap;
  final Duration minDuration;

  static final _sentenceEnd = RegExp(r'[.!?…]["”)]?$');
  static final _noise = RegExp(r'^\s*[\[(].*[\])]\s*$'); // [MUSIC], (applause)

  /// Phrases Whisper invents over silence/music (training-data artefacts).
  static final _artefact = RegExp(
    '^(thanks? for watching|thank you for watching|please subscribe.*|'
    r'subtitles? by .*|translated by .*|www\..*|.*amara\.org.*|[♪♫ ]+)[.! ]*$',
    caseSensitive: false,
  );

  static bool isArtefact(String text) => _artefact.hasMatch(text.trim());

  List<TranscriptSegment> merge(List<TranscriptSegment> input) {
    final clean =
        input
            .map(
              (s) => TranscriptSegment(
                start: s.start,
                end: s.end,
                text: s.text.replaceAll(RegExp(r'\s+'), ' ').trim(),
              ),
            )
            .where(
              (s) =>
                  s.text.isNotEmpty &&
                  !_noise.hasMatch(s.text) &&
                  !isArtefact(s.text),
            )
            .toList()
          ..sort((a, b) => a.start.compareTo(b.start));

    final out = <TranscriptSegment>[];
    for (final s in clean) {
      if (out.isEmpty) {
        out.add(s);
        continue;
      }
      final prev = out.last;
      final gap = s.start - prev.end;
      final combinedText = '${prev.text} ${s.text}';
      final canMerge =
          gap <= maxGap &&
          !_sentenceEnd.hasMatch(prev.text) &&
          combinedText.length <= maxChars &&
          s.end - prev.start <= maxDuration;
      if (canMerge) {
        out[out.length - 1] = TranscriptSegment(
          start: prev.start,
          end: s.end,
          text: combinedText,
        );
      } else {
        out.add(s);
      }
    }
    return _repair(_dropLoops(_split(out)));
  }

  /// Splits a segment that is too long to read into clause-sized cues, with
  /// times shared out by character count.
  List<TranscriptSegment> _split(List<TranscriptSegment> input) {
    final out = <TranscriptSegment>[];
    for (final s in input) {
      final tooLong =
          s.text.length > maxChars * 1.25 ||
          s.end - s.start > maxDuration * 1.5;
      if (!tooLong) {
        out.add(s);
        continue;
      }
      final pieces = _pack(s.text);
      if (pieces.length < 2) {
        out.add(s);
        continue;
      }
      final total = pieces.fold<int>(0, (a, p) => a + p.length);
      final span = (s.end - s.start).inMicroseconds;
      var used = 0;
      for (final p in pieces) {
        final from = s.start + Duration(microseconds: span * used ~/ total);
        used += p.length;
        final to = s.start + Duration(microseconds: span * used ~/ total);
        out.add(TranscriptSegment(start: from, end: to, text: p));
      }
    }
    return out;
  }

  /// Greedy-packs clauses (split at . ? ! , ; :) into pieces <= [maxChars].
  List<String> _pack(String text) {
    final clauses = text
        .split(RegExp(r'(?<=[.!?…,;:])\s+'))
        .expand(_breakLongWords)
        .toList();
    final pieces = <String>[];
    var current = '';
    for (final c in clauses) {
      final next = current.isEmpty ? c : '$current $c';
      if (next.length <= maxChars || current.isEmpty) {
        current = next;
      } else {
        pieces.add(current);
        current = c;
      }
    }
    if (current.isNotEmpty) pieces.add(current);
    return pieces;
  }

  /// A single clause longer than [maxChars] is cut at word boundaries.
  Iterable<String> _breakLongWords(String clause) sync* {
    if (clause.length <= maxChars) {
      yield clause;
      return;
    }
    var line = '';
    for (final w in clause.split(' ')) {
      final next = line.isEmpty ? w : '$line $w';
      if (next.length > maxChars && line.isNotEmpty) {
        yield line;
        line = w;
      } else {
        line = next;
      }
    }
    if (line.isNotEmpty) yield line;
  }

  /// Whisper sometimes loops the same sentence over silence: keep the first
  /// two occurrences of a run, drop the rest.
  List<TranscriptSegment> _dropLoops(List<TranscriptSegment> input) {
    final out = <TranscriptSegment>[];
    var run = 0;
    String? last;
    for (final s in input) {
      final key = s.text.toLowerCase();
      run = key == last ? run + 1 : 1;
      last = key;
      if (run <= 2) out.add(s);
    }
    return out;
  }

  /// Ensures min duration and no overlap with the next cue.
  List<TranscriptSegment> _repair(List<TranscriptSegment> cues) {
    final out = <TranscriptSegment>[];
    for (var i = 0; i < cues.length; i++) {
      final c = cues[i];
      var end = c.end;
      if (end - c.start < minDuration) end = c.start + minDuration;
      if (i + 1 < cues.length && end > cues[i + 1].start) {
        end = cues[i + 1].start;
      }
      if (end <= c.start) continue;
      out.add(TranscriptSegment(start: c.start, end: end, text: c.text));
    }
    return out;
  }
}
