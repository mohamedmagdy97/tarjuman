import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;

import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';
import 'package:tarjuman/features/player/domain/repositories/subtitle_repository.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
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
    this.overlap = const Duration(seconds: 6),
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
  final Duration overlap;

  Stream<ProcessingEvent> call({
    required String videoId,
    required EngineKind kind,
    required CancelToken cancel,
    SourceLanguage language = SourceLanguage.en,
  }) {
    final out = StreamController<ProcessingEvent>();
    unawaited(
      _run(videoId, kind, language, cancel, out).whenComplete(out.close),
    );
    return out.stream;
  }

  Future<void> _run(
    String videoId,
    EngineKind kind,
    SourceLanguage language,
    CancelToken cancel,
    StreamController<ProcessingEvent> out,
  ) async {
    Future<void> fail(Video? v, Failure f) async {
      if (v != null) {
        await _videos.update(v.copyWith(status: VideoStatus.failed));
      }
      debugPrint('[pipeline] failed: ${f.runtimeType} ${f.message}');
      out.add(ProcessingFailed(f));
    }

    final got = await _videos.get(videoId);
    if (got case Err(:final failure)) {
      out.add(ProcessingFailed(failure));
      return;
    }
    var video = (got as Success<Video>).value;

    final acquired = await _engines.acquire(kind, language: language);
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

      // The duration was measured at import; only re-probe if it's missing.
      var total = video.duration ?? Duration.zero;
      if (total <= Duration.zero) {
        final probed = await _audio.probeDuration(video.path);
        if (probed case Err(:final failure)) return fail(video, failure);
        total = (probed as Success<Duration>).value;
      }

      // Resume right after the last saved cue (cues are saved per chunk).
      final existing = await _subtitles.load(videoId);
      var startMs = 0;
      if (existing case Success(:final value) when !value.isEmpty) {
        startMs = value.cues.last.end.inMilliseconds;
      }

      final clock = Stopwatch()..start();
      final baseMs = startMs;
      var cursor = Duration(milliseconds: startMs);
      while (cursor < total) {
        if (cancel.isCancelled) return _cancelled(video, out);
        // Each window reaches `overlap` past the chunk boundary so a sentence
        // crossing it is transcribed whole; the next window then starts where
        // the last kept sentence ended instead of at a fixed grid line.
        final boundary = cursor + chunk;
        final isLast = boundary + overlap >= total;
        final length = isLast ? total - cursor : chunk + overlap;

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
            final keep = isLast
                ? value
                : value.where((c) => c.start < boundary).toList();
            await _subtitles.append(videoId, keep);
            if (isLast) {
              cursor = total;
            } else {
              final lastEnd = keep.isEmpty ? boundary : keep.last.end;
              cursor = lastEnd > boundary ? lastEnd : boundary;
            }
        }
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
