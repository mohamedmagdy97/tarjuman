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
    this.speaker = 0,
  }) : assert(end > start, 'cue must have positive duration');

  final Duration start;
  final Duration end;
  final String text;
  final String? original;
  final CueStatus status;

  /// 0 = untagged; 1..4 map to subtitle colours.
  final int speaker;

  SubtitleCue copyWith({String? text, CueStatus? status, int? speaker}) =>
      SubtitleCue(
        start: start,
        end: end,
        text: text ?? this.text,
        original: original,
        status: status ?? this.status,
        speaker: speaker ?? this.speaker,
      );

  bool contains(Duration position) => position >= start && position < end;

  @override
  bool operator ==(Object other) =>
      other is SubtitleCue &&
      other.start == start &&
      other.end == end &&
      other.text == text &&
      other.original == original &&
      other.status == status &&
      other.speaker == speaker;

  @override
  int get hashCode => Object.hash(start, end, text, original, status, speaker);
}
