import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarjuman/core/database/app_database.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/player/data/subtitle_repository_impl.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_timeline.dart';

void main() {
  late AppDatabase db;
  late SubtitleRepositoryImpl repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SubtitleRepositoryImpl(db);
    await db
        .into(db.videos)
        .insert(
          VideosCompanion.insert(
            id: 'v1',
            title: 't',
            path: '/x.mp4',
            createdAt: DateTime(2026),
          ),
        );
  });
  tearDown(() => db.close());

  SubtitleCue cue(int s, String t) => SubtitleCue(
    start: Duration(seconds: s),
    end: Duration(seconds: s + 2),
    text: t,
  );

  test(
    'replace stores cues, marks video ready, and load returns them sorted',
    () async {
      await repo.replace(
        'v1',
        SubtitleTimeline([cue(5, 'b'), cue(1, 'a')]),
        SubtitleOrigin.imported,
      );

      final loaded = (await repo.load('v1') as Success<SubtitleTimeline>).value;
      expect(loaded.cues.map((c) => c.text), ['a', 'b']);

      final video = await db.select(db.videos).getSingle();
      expect(video.status, 'ready');
      expect(video.origin, 'imported');
    },
  );

  test('replace overwrites previous cues', () async {
    await repo.replace(
      'v1',
      SubtitleTimeline([cue(1, 'old')]),
      SubtitleOrigin.imported,
    );
    await repo.replace(
      'v1',
      SubtitleTimeline([cue(2, 'new')]),
      SubtitleOrigin.imported,
    );
    final loaded = (await repo.load('v1') as Success<SubtitleTimeline>).value;
    expect(loaded.cues.single.text, 'new');
  });

  test('deleting a video cascades to its cues', () async {
    await repo.replace(
      'v1',
      SubtitleTimeline([cue(1, 'a')]),
      SubtitleOrigin.imported,
    );
    await (db.delete(db.videos)..where((t) => t.id.equals('v1'))).go();
    expect(await db.select(db.cues).get(), isEmpty);
  });
}
