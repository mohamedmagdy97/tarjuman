import 'package:equatable/equatable.dart';

/// A subtitle line matching a library-wide search.
class CueHit extends Equatable {
  const CueHit({
    required this.videoId,
    required this.videoTitle,
    required this.start,
    required this.text,
    this.original,
  });

  final String videoId;
  final String videoTitle;
  final Duration start;
  final String text;
  final String? original;

  @override
  List<Object?> get props => [videoId, videoTitle, start, text, original];
}
