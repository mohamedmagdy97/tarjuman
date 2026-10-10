import 'package:tarjuman/features/player/domain/entities/subtitle_timeline.dart';

class SubtitleSerializer {
  const SubtitleSerializer();

  /// SubRip. With [includeOriginal] each cue carries the English line first.
  String toSrt(SubtitleTimeline timeline, {bool includeOriginal = false}) {
    final b = StringBuffer();
    var i = 1;
    for (final c in timeline.cues) {
      b
        ..writeln(i++)
        ..writeln('${_t(c.start)} --> ${_t(c.end)}');
      if (includeOriginal && c.original != null) b.writeln(c.original);
      b
        ..writeln(c.text)
        ..writeln();
    }
    return b.toString();
  }

  /// Readable transcript: one paragraph per cue, optionally with the source
  /// line first.
  String toText(SubtitleTimeline timeline, {bool includeOriginal = false}) {
    final b = StringBuffer();
    for (final c in timeline.cues) {
      if (includeOriginal && c.original != null) b.writeln(c.original);
      b
        ..writeln(c.text)
        ..writeln();
    }
    return b.toString().trimRight();
  }

  String _t(Duration d) {
    String p(int n, [int w = 2]) => n.toString().padLeft(w, '0');
    return '${p(d.inHours)}:${p(d.inMinutes.remainder(60))}:'
        '${p(d.inSeconds.remainder(60))},${p(d.inMilliseconds.remainder(1000), 3)}';
  }
}
