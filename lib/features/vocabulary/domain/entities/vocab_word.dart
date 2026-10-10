import 'package:equatable/equatable.dart';

class VocabWord extends Equatable {
  const VocabWord({
    required this.id,
    required this.word,
    required this.translation,
    required this.createdAt,
    this.sentence,
  });

  final int id;
  final String word;
  final String translation;
  final String? sentence;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, word, translation, sentence, createdAt];
}
