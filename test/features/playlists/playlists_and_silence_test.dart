import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarjuman/core/database/app_database.dart' show AppDatabase;
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/core/settings/settings_store.dart';
import 'package:tarjuman/features/downloads/presentation/cubit/downloads_cubit.dart';
import 'package:tarjuman/features/library/data/links/youtube_link_lister.dart';
import 'package:tarjuman/features/library/data/media_storage.dart';
import 'package:tarjuman/features/library/data/video_repository_impl.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/usecases/export_video_file.dart';
import 'package:tarjuman/features/library/domain/usecases/import_from_url.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_timeline.dart';
import 'package:tarjuman/features/playlists/data/playlist_repository_impl.dart';

class _Storage extends MediaStorage {
  @override
  Future<String> persist(String sourcePath, {required String id}) async =>
      sourcePath;
  @override
  Future<void> delete(String path) async {}
}

class _Import extends Mock implements ImportFromUrl {}

class _Export extends Mock implements ExportVideoFile {}

class _Settings extends Fake implements SettingsStore {
  @override
  bool readAutoSaveDownloads() => false;
}

SubtitleCue cue(int startSec, int endSec) => SubtitleCue(
  start: Duration(seconds: startSec),
  end: Duration(seconds: endSec),
  text: 'x',
);

void main() {
  group('SubtitleTimeline.inSilence', () {
    final timeline = SubtitleTimeline([cue(2, 4), cue(10, 12), cue(12, 14)]);

    test('long quiet stretch is silent, with a margin at both ends', () {
      expect(timeline.inSilence(const Duration(seconds: 6)), isTrue);
      expect(timeline.inSilence(const Duration(milliseconds: 4200)), isFalse);
      expect(timeline.inSilence(const Duration(milliseconds: 9700)), isFalse);
    });

    test('speech, short gaps and the tail are not silent', () {
      expect(timeline.inSilence(const Duration(seconds: 3)), isFalse);
      expect(timeline.inSilence(const Duration(seconds: 12)), isFalse);
      expect(timeline.inSilence(const Duration(seconds: 15)), isFalse);
      // The quiet intro before the first line counts, but not its very start.
      expect(timeline.inSilence(const Duration(seconds: 1)), isTrue);
      expect(timeline.inSilence(const Duration(milliseconds: 200)), isFalse);
      expect(
        const SubtitleTimeline.empty().inSilence(const Duration(seconds: 5)),
        isFalse,
      );
    });
  });

  group('PlaylistRepository', () {
    late AppDatabase db;
    late VideoRepositoryImpl videos;
    late PlaylistRepositoryImpl repo;
    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      videos = VideoRepositoryImpl(db, _Storage());
      repo = PlaylistRepositoryImpl(db);
    });
    tearDown(() => db.close());

    Future<String> addVideo(String title) async =>
        ((await videos.add(title: title, path: '/$title.mp4'))
                as Success<Video>)
            .value
            .id;

    test(
      'keeps order, skips duplicates, closes gaps and remembers last',
      () async {
        final a = await addVideo('a');
        final b = await addVideo('b');
        final c = await addVideo('c');
        final list = await repo.create('Season 1');

        await repo.addVideos(list.id, [b, a]);
        await repo.addVideos(list.id, [a, c]);
        expect(await repo.videoIds(list.id), [b, a, c]);

        await repo.removeVideo(list.id, a);
        expect(await repo.videoIds(list.id), [b, c]);

        await repo.setLast(list.id, c);
        final loaded = await repo.get(list.id);
        expect(loaded?.lastVideoId, c);
        expect(loaded?.count, 2);
        expect((await repo.watchVideos(list.id).first).map((v) => v.id), [
          b,
          c,
        ]);
      },
    );

    test('getOrCreate reuses a playlist by name; delete cascades', () async {
      final one = await repo.getOrCreate('Course');
      final two = await repo.getOrCreate('Course');
      expect(two.id, one.id);
      final v = await addVideo('v');
      await repo.addVideos(one.id, [v]);
      await repo.delete(one.id);
      expect(await repo.get(one.id), isNull);
      expect(await videos.get(v), isA<Success<Video>>());
    });
  });

  test('YouTube lister recognises playlists and channels only', () {
    final lister = YoutubeLinkLister();
    expect(
      lister.supports(Uri.parse('https://www.youtube.com/playlist?list=PL123')),
      isTrue,
    );
    expect(
      lister.supports(Uri.parse('https://www.youtube.com/@somechannel')),
      isTrue,
    );
    expect(
      lister.supports(Uri.parse('https://www.youtube.com/watch?v=abc')),
      isFalse,
    );
    expect(
      lister.supports(
        Uri.parse('https://www.youtube.com/watch?v=a&list=RDabc'),
      ),
      isFalse,
    );
    expect(lister.supports(Uri.parse('https://example.com/@x')), isFalse);
  });

  test('playlist downloads join the playlist strictly in order', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final videos = VideoRepositoryImpl(db, _Storage());
    final repo = PlaylistRepositoryImpl(db);
    final ids = <String, String>{};
    for (final n in ['e1', 'e2', 'e3']) {
      ids[n] = ((await videos.add(title: n, path: '/$n.mp4')) as Success<Video>)
          .value
          .id;
    }
    final gates = {for (final n in ids.keys) n: Completer<Result<Video>>()};
    final import = _Import();
    for (final e in gates.entries) {
      when(
        () => import(
          e.key,
          referer: any(named: 'referer'),
          onProgress: any(named: 'onProgress'),
          cancel: any(named: 'cancel'),
        ),
      ).thenAnswer((_) => e.value.future);
    }
    final cubit =
        DownloadsCubit(
          import,
          _Export(),
          _Settings(),
          playlists: repo,
          concurrency: 3,
        )..add([
          for (var i = 0; i < 3; i++)
            DownloadRequest(
              url: 'e${i + 1}',
              playlist: 'Series',
              order: i,
            ),
        ]);
    await Future<void>.delayed(Duration.zero);

    Video v(String n) => Video(
      id: ids[n]!,
      title: n,
      path: '/$n',
      createdAt: DateTime(2026),
    );
    // Episode 2 finishes first: it must wait for episode 1.
    gates['e2']!.complete(Result.success(v('e2')));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(
      (await repo.getOrCreate('Series')).count,
      0,
    );
    gates['e1']!.complete(Result.success(v('e1')));
    gates['e3']!.complete(Result.success(v('e3')));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final list = await repo.getOrCreate('Series');
    expect(await repo.videoIds(list.id), [ids['e1'], ids['e2'], ids['e3']]);
    await cubit.close();
  });
}
