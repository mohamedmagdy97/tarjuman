import 'package:tarjuman/features/vocabulary/domain/entities/vocab_word.dart';

abstract interface class VocabularyRepository {
  Stream<List<VocabWord>> watchAll();
  Future<void> add({
    required String word,
    required String translation,
    String? sentence,
  });
  Future<void> remove(int id);

  /// True if [word] (case-insensitive) is already saved.
  Future<bool> contains(String word);
}
