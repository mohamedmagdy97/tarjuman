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
