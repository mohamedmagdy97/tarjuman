import 'package:drift/drift.dart';
import 'package:tarjuman/core/database/app_database.dart' as db;
import 'package:tarjuman/features/glossary/domain/entities/glossary_entry.dart';
import 'package:tarjuman/features/glossary/domain/repositories/glossary_repository.dart';

class GlossaryRepositoryImpl implements GlossaryRepository {
  GlossaryRepositoryImpl(this._db);
  final db.AppDatabase _db;

  GlossaryEntry _map(db.GlossaryData r) => GlossaryEntry(
    id: r.id,
    term: r.term,
    arabic: r.arabic,
    videoId: r.videoId,
  );

  @override
  Stream<List<GlossaryEntry>> watch({String? videoId}) =>
      (_db.select(_db.glossary)..where(
            (t) => videoId == null
                ? t.videoId.isNull()
                : t.videoId.equals(videoId),
          ))
          .watch()
          .map((rows) => rows.map(_map).toList());

  @override
  Future<List<GlossaryEntry>> effective({String? videoId}) async {
    final rows =
        await (_db.select(_db.glossary)..where(
              (t) => videoId == null
                  ? t.videoId.isNull()
                  : t.videoId.isNull() | t.videoId.equals(videoId),
            ))
            .get();
    // Video-specific terms first so they win over a global duplicate.
    return rows.map(_map).toList()..sort(
      (a, b) => (b.videoId == null ? 0 : 1) - (a.videoId == null ? 0 : 1),
    );
  }

  @override
  Future<void> add(String term, String arabic, {String? videoId}) => _db
      .into(_db.glossary)
      .insert(
        db.GlossaryCompanion.insert(
          term: term.trim(),
          arabic: arabic.trim(),
          videoId: Value(videoId),
        ),
      );

  @override
  Future<void> remove(int id) =>
      (_db.delete(_db.glossary)..where((t) => t.id.equals(id))).go();
}
