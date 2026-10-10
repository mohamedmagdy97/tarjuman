import 'package:tarjuman/core/database/app_database.dart' as db;
import 'package:tarjuman/features/glossary/domain/entities/glossary_entry.dart';
import 'package:tarjuman/features/glossary/domain/repositories/glossary_repository.dart';

class GlossaryRepositoryImpl implements GlossaryRepository {
  GlossaryRepositoryImpl(this._db);
  final db.AppDatabase _db;

  GlossaryEntry _map(db.GlossaryData r) =>
      GlossaryEntry(id: r.id, term: r.term, arabic: r.arabic);

  @override
  Stream<List<GlossaryEntry>> watchAll() =>
      _db.select(_db.glossary).watch().map((rows) => rows.map(_map).toList());

  @override
  Future<List<GlossaryEntry>> all() async =>
      (await _db.select(_db.glossary).get()).map(_map).toList();

  @override
  Future<void> add(String term, String arabic) => _db
      .into(_db.glossary)
      .insert(
        db.GlossaryCompanion.insert(term: term.trim(), arabic: arabic.trim()),
      );

  @override
  Future<void> remove(int id) =>
      (_db.delete(_db.glossary)..where((t) => t.id.equals(id))).go();
}
