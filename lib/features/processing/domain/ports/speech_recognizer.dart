import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/processing/domain/entities/transcript_segment.dart';

abstract interface class SpeechRecognizer {
  /// English speech in [wavPath] -> timed segments relative to the file start.
  Future<Result<List<TranscriptSegment>>> transcribe(
    String wavPath, {
    CancelToken? cancel,
  });

  Future<void> dispose();
}
