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

  /// Epoch ms of the last playback (0 = never); drives "continue watching".
  IntColumn get lastPlayedMs => integer().withDefault(const Constant(0))();

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

  /// 0 = not tagged; 1..4 pick a colour in the subtitle.
  IntColumn get speaker => integer().withDefault(const Constant(0))();
}

/// Words saved from the study sheet.
class Vocabulary extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text()();
  TextColumn get translation => text()();
  TextColumn get sentence => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  /// Spaced repetition: next review (epoch ms, 0 = due now), interval in
  /// days, ease factor and successful repetitions.
  IntColumn get dueAtMs => integer().withDefault(const Constant(0))();
  IntColumn get intervalDays => integer().withDefault(const Constant(0))();
  RealColumn get ease => real().withDefault(const Constant(2.5))();
  IntColumn get reps => integer().withDefault(const Constant(0))();
}

/// User terms applied before translation (English term -> Arabic term).
class Glossary extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get term => text()();
  TextColumn get arabic => text()();

  /// Null = applies to every video; otherwise only to that video.
  TextColumn get videoId => text().nullable()();
}

@DriftDatabase(tables: [Videos, Cues, Vocabulary, Glossary])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'tarjuman'));
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.addColumn(videos, videos.lastPositionMs);
      if (from < 3) await m.addColumn(videos, videos.isFavorite);
      if (from < 4) await m.createTable(vocabulary);
      if (from == 4) {
        await m.addColumn(vocabulary, vocabulary.dueAtMs);
        await m.addColumn(vocabulary, vocabulary.intervalDays);
        await m.addColumn(vocabulary, vocabulary.ease);
        await m.addColumn(vocabulary, vocabulary.reps);
      }
      if (from < 5) await m.createTable(glossary);
      if (from < 6) await m.addColumn(videos, videos.lastPlayedMs);
      if (from < 7) {
        await m.addColumn(cues, cues.speaker);
        // Glossary created at v5/v6 predates videoId; a fresh create has it.
        if (from >= 5) await m.addColumn(glossary, glossary.videoId);
      }
    },
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        'CREATE INDEX idx_cues_video_start ON cues (video_id, start_ms)',
      );
    },
  );
}
