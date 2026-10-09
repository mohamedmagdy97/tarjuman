import 'dart:async';

import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';
import 'package:tarjuman/features/player/domain/repositories/subtitle_repository.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/domain/ports/audio_extractor.dart';
import 'package:tarjuman/features/processing/domain/ports/engine_provider.dart';
import 'package:tarjuman/features/processing/domain/usecases/process_range.dart';

/// Pre-process mode: walks the video in fixed chunks, persisting cues after
/// each one. Killing the app loses at most one chunk; running it again
/// resumes from the last completed chunk boundary.
class RunProcessingPipeline {
  const RunProcessingPipeline({
    required VideoRepository videos,
    required SubtitleRepository subtitles,
    required AudioExtractor audio,
    required EngineProvider engines,
    required ProcessRange processRange,
    this.chunk = const Duration(minutes: 3),
  }) : _videos = videos,
       _subtitles = subtitles,
       _audio = audio,
       _engines = engines,
       _processRange = processRange;

  final VideoRepository _videos;
  final SubtitleRepository _subtitles;
  final AudioExtractor _audio;
  final EngineProvider _engines;
  final ProcessRange _processRange;
  final Duration chunk;

  Stream<ProcessingEvent> call({
    required String videoId,
    required EngineKind kind,
    required CancelToken cancel,
  }) {
    final out = StreamController<ProcessingEvent>();
    unawaited(_run(videoId, kind, cancel, out).whenComplete(out.close));
    return out.stream;
  }

  Future<void> _run(
    String videoId,
    EngineKind kind,
    CancelToken cancel,
    StreamController<ProcessingEvent> out,
  ) async {
    Future<void> fail(Video? v, Failure f) async {
      if (v != null) {
        await _videos.update(v.copyWith(status: VideoStatus.failed));
      }
      out.add(ProcessingFailed(f));
    }

    final got = await _videos.get(videoId);
    if (got case Err(:final failure)) {
      out.add(ProcessingFailed(failure));
      return;
    }
    var video = (got as Success<Video>).value;

    final acquired = await _engines.acquire(kind);
    if (acquired case Err(:final failure)) {
      out.add(ProcessingFailed(failure));
      return;
    }
    final engines = (acquired as Success<EngineSet>).value;

    try {
      video = video.copyWith(status: VideoStatus.processing);
      await _videos.update(video);
      out.add(
        const ProcessingProgress(
          stage: ProcessingStage.preparing,
          fraction: 0,
        ),
      );

      final probed = await _audio.probeDuration(video.path);
      if (probed case Err(:final failure)) return fail(video, failure);
      final total = (probed as Success<Duration>).value;

      // Resume: drop the possibly half-written last chunk, restart from it.
      final existing = await _subtitles.load(videoId);
      var startMs = 0;
      if (existing case Success(:final value) when !value.isEmpty) {
        final lastEnd = value.cues.last.end.inMilliseconds;
        startMs = (lastEnd ~/ chunk.inMilliseconds) * chunk.inMilliseconds;
      }
      await _subtitles.deleteFrom(videoId, Duration(milliseconds: startMs));

      final clock = Stopwatch()..start();
      final baseMs = startMs;
      var cursor = Duration(milliseconds: startMs);
      while (cursor < total) {
        if (cancel.isCancelled) return _cancelled(video, out);
        final length = total - cursor < chunk ? total - cursor : chunk;

        double fractionAt(Duration d) => total.inMilliseconds == 0
            ? 0
            : d.inMilliseconds / total.inMilliseconds;

        final result = await _processRange(
          mediaPath: video.path,
          engines: engines,
          start: cursor,
          length: length,
          cancel: cancel,
          onStage: (stage) {
            final done = (cursor.inMilliseconds - baseMs).toDouble();
            final remainingMs = done <= 0
                ? null
                : ((total.inMilliseconds - cursor.inMilliseconds) *
                          clock.elapsedMilliseconds /
                          done)
                      .round();
            out.add(
              ProcessingProgress(
                stage: stage,
                fraction: fractionAt(cursor),
                remaining: remainingMs == null
                    ? null
                    : Duration(milliseconds: remainingMs),
              ),
            );
          },
        );

        switch (result) {
          case Err(:final failure):
            if (failure is CancelledFailure) return _cancelled(video, out);
            return fail(video, failure);
          case Success(:final value):
            await _subtitles.append(videoId, value);
        }
        cursor += length;
      }

      final origin = kind == EngineKind.online
          ? SubtitleOrigin.online
          : SubtitleOrigin.offline;
      await _videos.update(
        video.copyWith(
          status: VideoStatus.ready,
          origin: origin,
          duration: total,
        ),
      );
      out
        ..add(
          const ProcessingProgress(
            stage: ProcessingStage.translating,
            fraction: 1,
          ),
        )
        ..add(const ProcessingDone());
    } finally {
      await engines.dispose();
    }
  }

  Future<void> _cancelled(
    Video v,
    StreamController<ProcessingEvent> out,
  ) async {
    await _videos.update(v.copyWith(status: VideoStatus.imported));
    out.add(const ProcessingCancelled());
  }
}
