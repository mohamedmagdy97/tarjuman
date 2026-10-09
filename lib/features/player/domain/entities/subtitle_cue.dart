import 'package:meta/meta.dart';

enum CueStatus { partial, committed, edited }

@immutable
class SubtitleCue {
  const SubtitleCue({
    required this.start,
    required this.end,
    required this.text,
    this.original,
    this.status = CueStatus.committed,
  }) : assert(end > start, 'cue must have positive duration');

  final Duration start;
  final Duration end;
  final String text;
  final String? original;
  final CueStatus status;

  bool contains(Duration position) => position >= start && position < end;

  @override
  bool operator ==(Object other) =>
      other is SubtitleCue &&
      other.start == start &&
      other.end == end &&
      other.text == text &&
      other.original == original &&
      other.status == status;

  @override
  int get hashCode => Object.hash(start, end, text, original, status);
}
