import 'package:drift/drift.dart';
import 'package:tarjuman/core/database/app_database.dart' as db;
import 'package:tarjuman/features/vocabulary/domain/entities/vocab_word.dart';
import 'package:tarjuman/features/vocabulary/domain/repositories/vocabulary_repository.dart';
import 'package:tarjuman/features/vocabulary/domain/services/spaced_repetition.dart';

class VocabularyRepositoryImpl implements VocabularyRepository {
  VocabularyRepositoryImpl(this._db);
  final db.AppDatabase _db;

  @override
  Stream<List<VocabWord>> watchAll() {
    final q = _db.select(_db.vocabulary)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return q.watch().map(
      (rows) => [
        for (final r in rows) _map(r),
      ],
    );
  }

  VocabWord _map(db.VocabularyData r) => VocabWord(
    id: r.id,
    word: r.word,
    translation: r.translation,
    sentence: r.sentence,
    createdAt: r.createdAt,
    dueAt: r.dueAtMs == 0
        ? null
        : DateTime.fromMillisecondsSinceEpoch(r.dueAtMs),
    intervalDays: r.intervalDays,
    ease: r.ease,
    reps: r.reps,
  );

  @override
  Future<List<VocabWord>> all() async =>
      (await _db.select(_db.vocabulary).get()).map(_map).toList();

  @override
  Future<void> saveSchedule(int id, CardSchedule schedule) =>
      (_db.update(_db.vocabulary)..where((t) => t.id.equals(id))).write(
        db.VocabularyCompanion(
          dueAtMs: Value(schedule.dueAt.millisecondsSinceEpoch),
          intervalDays: Value(schedule.intervalDays),
          ease: Value(schedule.ease),
          reps: Value(schedule.reps),
        ),
      );

  @override
  Future<void> add({
    required String word,
    required String translation,
    String? sentence,
  }) => _db
      .into(_db.vocabulary)
      .insert(
        db.VocabularyCompanion.insert(
          word: word.toLowerCase(),
          translation: translation,
          sentence: Value(sentence),
          createdAt: DateTime.now(),
        ),
      );

  @override
  Future<void> remove(int id) =>
      (_db.delete(_db.vocabulary)..where((t) => t.id.equals(id))).go();

  @override
  Future<bool> contains(String word) async =>
      (await (_db.select(
        _db.vocabulary,
      )..where((t) => t.word.equals(word.toLowerCase()))).getSingleOrNull()) !=
      null;
}
