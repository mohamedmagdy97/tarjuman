import 'package:tarjuman/features/vocabulary/domain/entities/vocab_word.dart';
import 'package:tarjuman/features/vocabulary/domain/services/spaced_repetition.dart';

abstract interface class VocabularyRepository {
  Stream<List<VocabWord>> watchAll();
  Future<void> add({
    required String word,
    required String translation,
    String? sentence,
  });
  Future<void> remove(int id);

  /// Stores the new schedule after a review.
  Future<void> saveSchedule(int id, CardSchedule schedule);

  Future<List<VocabWord>> all();

  /// True if [word] (case-insensitive) is already saved.
  Future<bool> contains(String word);
}
