import 'package:equatable/equatable.dart';

class GlossaryEntry extends Equatable {
  const GlossaryEntry({
    required this.id,
    required this.term,
    required this.arabic,
    this.videoId,
  });

  final int id;
  final String term;
  final String arabic;

  /// Null = global; otherwise only for this video.
  final String? videoId;

  @override
  List<Object?> get props => [id, term, arabic, videoId];
}
