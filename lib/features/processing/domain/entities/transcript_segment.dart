import 'package:equatable/equatable.dart';

class TranscriptSegment extends Equatable {
  const TranscriptSegment({
    required this.start,
    required this.end,
    required this.text,
  });

  final Duration start;
  final Duration end;
  final String text;

  TranscriptSegment shifted(Duration by) =>
      TranscriptSegment(start: start + by, end: end + by, text: text);

  @override
  List<Object?> get props => [start, end, text];
}
