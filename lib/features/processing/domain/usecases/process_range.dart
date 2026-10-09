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

  Future<Result<List<SubtitleCue>>> call({
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
    final segments = _segmenter
        .merge((transcript as Success<List<TranscriptSegment>>).value)
        .map((s) => s.shifted(start))
        .toList();
    if (segments.isEmpty) return const Result.success([]);

    onStage?.call(ProcessingStage.translating);
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
}
