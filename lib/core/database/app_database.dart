import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Videos extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get path => text()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('imported'))();
  TextColumn get origin => text().withDefault(const Constant('none'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Cues extends Table {
  IntColumn get rowId => integer().autoIncrement()();
  TextColumn get videoId =>
      text().references(Videos, #id, onDelete: KeyAction.cascade)();
  IntColumn get startMs => integer()();
  IntColumn get endMs => integer()();
  TextColumn get body => text()();
  TextColumn get original => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('committed'))();
}

@DriftDatabase(tables: [Videos, Cues])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'tarjuman'));
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        'CREATE INDEX idx_cues_video_start ON cues (video_id, start_ms)',
      );
    },
  );
}
