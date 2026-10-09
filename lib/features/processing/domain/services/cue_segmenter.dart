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
            .where((s) => s.text.isNotEmpty && !_noise.hasMatch(s.text))
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
    return _repair(out);
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
