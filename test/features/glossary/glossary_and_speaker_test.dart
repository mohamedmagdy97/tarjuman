import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarjuman/core/database/app_database.dart' show AppDatabase;
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/glossary/data/glossary_repository_impl.dart';
import 'package:tarjuman/features/library/data/media_storage.dart';
import 'package:tarjuman/features/library/data/video_repository_impl.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/player/data/subtitle_repository_impl.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_timeline.dart';

class _Storage extends MediaStorage {
  @override
  Future<String> persist(String sourcePath, {required String id}) async =>
      sourcePath;
  @override
  Future<void> delete(String path) async {}
}

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test(
    'video glossary terms apply to that video and win over globals',
    () async {
      final repo = GlossaryRepositoryImpl(db);
      await repo.add('cell', 'خلية');
      await repo.add('cell', 'زنزانة', videoId: 'v1');
      await repo.add('gene', 'جين', videoId: 'v2');

      final forV1 = await repo.effective(videoId: 'v1');
      expect(forV1.map((e) => e.arabic), ['زنزانة', 'خلية']);
      expect((await repo.effective()).map((e) => e.term), ['cell']);
      expect((await repo.watch(videoId: 'v2').first).single.term, 'gene');
      expect((await repo.watch().first).single.arabic, 'خلية');
    },
  );

  test('speaker tags are stored, loaded and survive replace', () async {
    final videos = VideoRepositoryImpl(db, _Storage());
    final subs = SubtitleRepositoryImpl(db);
    final id =
        ((await videos.add(title: 't', path: '/v.mp4')) as Success<Video>)
            .value
            .id;
    await subs.replace(
      id,
      SubtitleTimeline([
        SubtitleCue(
          start: Duration.zero,
          end: const Duration(seconds: 2),
          text: 'a',
          speaker: 2,
        ),
        SubtitleCue(
          start: const Duration(seconds: 3),
          end: const Duration(seconds: 5),
          text: 'b',
        ),
      ]),
      SubtitleOrigin.offline,
    );
    await subs.setSpeaker(id, const Duration(seconds: 3), 4);
    final cues = (await subs.load(id) as Success<SubtitleTimeline>).value.cues;
    expect(cues.map((c) => c.speaker), [2, 4]);
  });
}
