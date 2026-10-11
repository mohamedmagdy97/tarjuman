import 'dart:async';

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
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/entities/transcript_segment.dart';
import 'package:tarjuman/features/processing/domain/ports/engine_provider.dart';
import 'package:tarjuman/features/processing/domain/ports/speech_recognizer.dart';
import 'package:tarjuman/features/processing/domain/ports/text_translator.dart';
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

  RunProcessingPipeline build({
    Failure? engineFailure,
    Duration firstChunk = const Duration(minutes: 1),
  }) => RunProcessingPipeline(
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
    firstChunk: firstChunk,
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
        if (e is ProcessingPartial) {
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

  test(
    'first window is short and each saved chunk emits a partial event',
    () async {
      final events = await build(firstChunk: const Duration(seconds: 30))(
        videoId: videoId,
        kind: EngineKind.offline,
        cancel: CancelToken(),
      ).toList();
      // 0 (30 s window), then 30, 90, 150 on the 1-minute grid.
      expect(audio.extracted, [
        Duration.zero,
        const Duration(seconds: 30),
        const Duration(seconds: 90),
        const Duration(seconds: 150),
      ]);
      expect(events.whereType<ProcessingPartial>(), hasLength(4));
      expect(events.last, isA<ProcessingDone>());
    },
  );

  test(
    'translation of one chunk overlaps with transcription of the next',
    () async {
      final order = <String>[];
      final gate = Completer<void>();
      final rec = _OrderRecognizer(order, onSecondCall: gate.complete);
      final translator = _GatedTranslator(order, gate.future);
      final pipeline = RunProcessingPipeline(
        videos: videos,
        subtitles: subtitles,
        audio: audio,
        engines: _SetProvider(
          EngineSet(recognizer: rec, translator: translator),
        ),
        processRange: ProcessRange(
          audio,
          const CueSegmenter(),
          (n) async => '/tmp/$n',
        ),
        chunk: const Duration(minutes: 1),
        firstChunk: const Duration(minutes: 1),
      );

      final events = await pipeline(
        videoId: videoId,
        kind: EngineKind.offline,
        cancel: CancelToken(),
      ).toList();

      expect(events.last, isA<ProcessingDone>());
      // Chunk 1's translation could only finish because chunk 2's recognition
      // had already started (the gate opens on the second recognizer call).
      expect(
        order.indexOf('transcribe#2'),
        lessThan(order.indexOf('translated#1')),
      );
    },
  );
}

class _OrderRecognizer implements SpeechRecognizer {
  _OrderRecognizer(this.order, {required this.onSecondCall});
  final List<String> order;
  final void Function() onSecondCall;
  int calls = 0;

  @override
  Future<Result<List<TranscriptSegment>>> transcribe(
    String wavPath, {
    CancelToken? cancel,
  }) async {
    calls++;
    order.add('transcribe#$calls');
    if (calls == 2) onSecondCall();
    return const Result.success([
      TranscriptSegment(
        start: Duration.zero,
        end: Duration(seconds: 2),
        text: 'Hello.',
      ),
    ]);
  }

  @override
  Future<void> dispose() async {}
}

class _GatedTranslator implements TextTranslator {
  _GatedTranslator(this.order, this.gate);
  final List<String> order;
  final Future<void> gate;
  int calls = 0;

  @override
  Future<Result<List<String>>> translateBatch(
    List<String> texts, {
    CancelToken? cancel,
  }) async {
    final n = ++calls;
    if (n == 1) await gate;
    order.add('translated#$n');
    return Result.success([for (final t in texts) 'ar:$t']);
  }

  @override
  Future<void> dispose() async {}
}

class _SetProvider implements EngineProvider {
  _SetProvider(this.set);
  final EngineSet set;

  @override
  Future<Result<EngineSet>> acquire(
    EngineKind kind, {
    SourceLanguage language = SourceLanguage.en,
    String? videoId,
  }) async => Result.success(set);

  @override
  Future<Result<TextTranslator>> acquireTranslator(
    SourceLanguage language, {
    String? videoId,
  }) async => Result.success(set.translator);
}
