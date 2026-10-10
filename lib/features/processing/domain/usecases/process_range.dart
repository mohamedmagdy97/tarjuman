import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/domain/entities/transcript_segment.dart';
import 'package:tarjuman/features/processing/domain/ports/audio_extractor.dart';
import 'package:tarjuman/features/processing/domain/ports/engine_provider.dart';
import 'package:tarjuman/features/processing/domain/services/cue_segmenter.dart';

typedef StageCallback = void Function(ProcessingStage stage);

/// Turns one time range of a media file into final Arabic cues:
/// extract audio -> transcribe -> merge into cues -> translate.
/// Shared by pre-process (sequential ranges) and live mode (on demand).
class ProcessRange {
  const ProcessRange(this._audio, this._segmenter, this._workPath);

  final AudioExtractor _audio;
  final CueSegmenter _segmenter;
  final Future<String> Function(String name) _workPath;

  /// Stage 1 (CPU heavy): audio extraction + speech recognition. Returns
  /// cue-sized segments with times relative to the whole media file.
  Future<Result<List<TranscriptSegment>>> transcribe({
    required String mediaPath,
    required EngineSet engines,
    required Duration start,
    required Duration length,
    CancelToken? cancel,
    StageCallback? onStage,
  }) async {
    final wav = await _workPath('range_${start.inMilliseconds}.wav');

    onStage?.call(ProcessingStage.extractingAudio);
    final extracted = await _audio.extractWav(
      mediaPath: mediaPath,
      outPath: wav,
      start: start,
      length: length,
      cancel: cancel,
    );
    if (extracted case Err(:final failure)) return Result.failure(failure);
    if (cancel?.isCancelled ?? false) {
      return const Result.failure(CancelledFailure());
    }

    onStage?.call(ProcessingStage.transcribing);
    final transcript = await engines.recognizer.transcribe(wav, cancel: cancel);
    if (transcript case Err(:final failure)) return Result.failure(failure);
    return Result.success(
      _segmenter
          .merge((transcript as Success<List<TranscriptSegment>>).value)
          .map((s) => s.shifted(start))
          .toList(),
    );
  }

  /// Stage 2: translation. Independent of the recognizer, so the pipeline
  /// runs it while the next range is being transcribed.
  Future<Result<List<SubtitleCue>>> translate({
    required List<TranscriptSegment> segments,
    required EngineSet engines,
    CancelToken? cancel,
  }) async {
    if (segments.isEmpty) return const Result.success([]);
    final translated = await engines.translator.translateBatch(
      segments.map((s) => s.text).toList(),
      cancel: cancel,
    );
    if (translated case Err(:final failure)) return Result.failure(failure);
    final arabic = (translated as Success<List<String>>).value;
    if (arabic.length != segments.length) {
      return const Result.failure(UnknownFailure('Translation size mismatch'));
    }
    return Result.success([
      for (var i = 0; i < segments.length; i++)
        SubtitleCue(
          start: segments[i].start,
          end: segments[i].end,
          text: arabic[i],
          original: segments[i].text,
        ),
    ]);
  }

  /// Both stages back to back (live mode).
  Future<Result<List<SubtitleCue>>> call({
    required String mediaPath,
    required EngineSet engines,
    required Duration start,
    required Duration length,
    CancelToken? cancel,
    StageCallback? onStage,
  }) async {
    final transcribed = await transcribe(
      mediaPath: mediaPath,
      engines: engines,
      start: start,
      length: length,
      cancel: cancel,
      onStage: onStage,
    );
    if (transcribed case Err(:final failure)) return Result.failure(failure);
    onStage?.call(ProcessingStage.translating);
    return translate(
      segments: (transcribed as Success<List<TranscriptSegment>>).value,
      engines: engines,
      cancel: cancel,
    );
  }
}
