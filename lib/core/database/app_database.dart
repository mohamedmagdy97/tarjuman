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
  IntColumn get lastPositionMs => integer().withDefault(const Constant(0))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

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

/// Words saved from the study sheet.
class Vocabulary extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text()();
  TextColumn get translation => text()();
  TextColumn get sentence => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [Videos, Cues, Vocabulary])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'tarjuman'));
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.addColumn(videos, videos.lastPositionMs);
      if (from < 3) await m.addColumn(videos, videos.isFavorite);
      if (from < 4) await m.createTable(vocabulary);
    },
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        'CREATE INDEX idx_cues_video_start ON cues (video_id, start_ms)',
      );
    },
  );
}
