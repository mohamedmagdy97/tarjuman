import 'package:meta/meta.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';

/// Cues sorted by start time. Lookup is O(log n); time is always audio time.
@immutable
class SubtitleTimeline {
  SubtitleTimeline(Iterable<SubtitleCue> cues)
    : cues = List.unmodifiable(
        cues.toList()..sort((a, b) => a.start.compareTo(b.start)),
      );

  const SubtitleTimeline.empty() : cues = const [];

  final List<SubtitleCue> cues;

  bool get isEmpty => cues.isEmpty;

  /// Active cue at [position], or null in a gap.
  SubtitleCue? activeAt(Duration position) {
    final i = _lastStartingAtOrBefore(position);
    if (i < 0) return null;
    // Overlaps are rare; walk back while an earlier cue could still be active.
    for (var j = i; j >= 0 && j > i - 3; j--) {
      if (cues[j].contains(position)) return cues[j];
    }
    return null;
  }

  /// True while [position] is inside a quiet stretch between two cues that is
  /// at least [minGap] long. Keeps a short lead-in/out so normal speed is back
  /// before the next line starts.
  bool inSilence(
    Duration position, {
    Duration minGap = const Duration(milliseconds: 1500),
    Duration margin = const Duration(milliseconds: 500),
  }) {
    if (cues.isEmpty) return false;
    final i = _lastStartingAtOrBefore(position);
    if (i + 1 >= cues.length) return false; // after the last line: leave alone
    if (activeAt(position) != null) return false;
    var prevEnd = Duration.zero;
    for (var j = i; j >= 0 && j > i - 3; j--) {
      if (cues[j].end > prevEnd) prevEnd = cues[j].end;
    }
    final nextStart = cues[i + 1].start;
    return nextStart - prevEnd >= minGap &&
        position >= prevEnd + margin &&
        position <= nextStart - margin;
  }

  /// Replaces an existing cue with the same start (partial -> committed) or inserts.
  SubtitleTimeline upsert(SubtitleCue cue) {
    final next = cues.where((c) => c.start != cue.start).toList()..add(cue);
    return SubtitleTimeline(next);
  }

  int _lastStartingAtOrBefore(Duration position) {
    var lo = 0;
    var hi = cues.length - 1;
    var found = -1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (cues[mid].start <= position) {
        found = mid;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    return found;
  }
}
