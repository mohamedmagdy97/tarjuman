import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/database/app_database.dart' show AppDatabase;
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/data/media_storage.dart';
import 'package:tarjuman/features/library/data/video_repository_impl.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/player/data/subtitle_repository_impl.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/domain/services/cue_segmenter.dart';
import 'package:tarjuman/features/processing/domain/usecases/process_range.dart';
import 'package:tarjuman/features/processing/domain/usecases/run_processing_pipeline.dart';

import '../../../fakes/fakes.dart';

class _NoopStorage extends MediaStorage {
  @override
  Future<String> persist(String sourcePath, {required String id}) async =>
      sourcePath;
  @override
  Future<void> delete(String path) async {}
}

void main() {
  late AppDatabase db;
  late VideoRepositoryImpl videos;
  late SubtitleRepositoryImpl subtitles;
  late FakeAudioExtractor audio;
  late FakeRecognizer recognizer;
  late String videoId;

  RunProcessingPipeline build({Failure? engineFailure}) =>
      RunProcessingPipeline(
        videos: videos,
        subtitles: subtitles,
        audio: audio,
        engines: FakeEngineProvider(recognizer, failure: engineFailure),
        processRange: ProcessRange(
          audio,
          const CueSegmenter(),
          (n) async => '/tmp/$n',
        ),
        chunk: const Duration(minutes: 1),
      );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    videos = VideoRepositoryImpl(db, _NoopStorage());
    subtitles = SubtitleRepositoryImpl(db);
    audio = FakeAudioExtractor(const Duration(minutes: 3, seconds: 30));
    recognizer = FakeRecognizer();
    videoId = ((await videos.add(title: 't', path: '/v.mp4')) as Success<Video>)
        .value
        .id;
  });
  tearDown(() => db.close());

  test('processes all chunks, stores Arabic cues, marks video ready', () async {
    final events = await build()(
      videoId: videoId,
      kind: EngineKind.offline,
      cancel: CancelToken(),
    ).toList();

    expect(events.last, isA<ProcessingDone>());
    expect(audio.extracted.length, 4); // 0,1,2,3 min (last chunk is 30 s)
    final video = ((await videos.get(videoId)) as Success<Video>).value;
    expect(video.status, VideoStatus.ready);
    expect(video.origin, SubtitleOrigin.offline);
    final cues = (await subtitles.load(videoId) as Success).value.cues as List;
    expect(cues.length, 4);
    expect(cues.first.text, 'ar:Hello.');
    expect(cues[1].start, const Duration(minutes: 1));
    expect(recognizer.disposed, isTrue);
  });

  test(
    'failure mid-way keeps finished chunks and marks video failed; rerun resumes',
    () async {
      recognizer = FakeRecognizer(failOnCall: 3);
      final first = await build()(
        videoId: videoId,
        kind: EngineKind.offline,
        cancel: CancelToken(),
      ).toList();
      expect(first.last, isA<ProcessingFailed>());
      expect(
        ((await videos.get(videoId)) as Success<Video>).value.status,
        VideoStatus.failed,
      );

      audio.extracted.clear();
      recognizer = FakeRecognizer();
      final second = await build()(
        videoId: videoId,
        kind: EngineKind.offline,
        cancel: CancelToken(),
      ).toList();
      expect(second.last, isA<ProcessingDone>());
      // Resumes right after the last saved cue (the 1:00-1:02 one).
      expect(audio.extracted.first, const Duration(seconds: 62));
      final cues =
          (await subtitles.load(videoId) as Success).value.cues as List;
      expect(cues.length, 5);
    },
  );

  test('missing engine fails fast without touching the video', () async {
    final events =
        await build(engineFailure: const ModelMissingFailure('speech'))(
          videoId: videoId,
          kind: EngineKind.offline,
          cancel: CancelToken(),
        ).toList();
    expect(events.single, isA<ProcessingFailed>());
    expect(audio.extracted, isEmpty);
    expect(
      ((await videos.get(videoId)) as Success<Video>).value.status,
      VideoStatus.imported,
    );
  });

  test(
    'cancel stops after current chunk and returns video to imported',
    () async {
      final cancel = CancelToken();
      final stream = build()(
        videoId: videoId,
        kind: EngineKind.offline,
        cancel: cancel,
      );
      final events = <ProcessingEvent>[];
      await for (final e in stream) {
        events.add(e);
        if (e is ProcessingProgress && e.stage == ProcessingStage.translating) {
          cancel.cancel();
        }
      }
      expect(events.last, isA<ProcessingCancelled>());
      expect(
        ((await videos.get(videoId)) as Success<Video>).value.status,
        VideoStatus.imported,
      );
    },
  );
}
