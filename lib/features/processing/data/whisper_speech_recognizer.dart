import 'dart:io';

import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/model_manager/domain/repositories/model_repository.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/entities/transcript_segment.dart';
import 'package:tarjuman/features/processing/domain/ports/speech_recognizer.dart';
import 'package:whisper_cpp_flutter_plus/whisper_cpp_flutter_plus.dart';

/// On-device ASR via whisper.cpp. The model is loaded once and reused for
/// every range of a job, then released in [dispose].
class WhisperSpeechRecognizer implements SpeechRecognizer {
  WhisperSpeechRecognizer(this._models, this._language);

  static const _maxNoSpeech = 0.6;

  final ModelRepository _models;
  final SourceLanguage _language;
  WhisperEngine? _engine;

  Future<WhisperEngine?> _load() async {
    if (_engine != null) return _engine;
    final path = await _models.installedSpeechModelPath(_language);
    if (path == null) return null;
    return _engine = await WhisperEngine.load(path);
  }

  @override
  Future<Result<List<TranscriptSegment>>> transcribe(
    String wavPath, {
    CancelToken? cancel,
  }) async {
    try {
      final engine = await _load();
      if (engine == null) {
        return const Result.failure(ModelMissingFailure('speech'));
      }
      final samples = await WhisperAudio.readWav(File(wavPath));
      final task = engine.transcribe(
        samples,
        options: TranscribeOptions(
          language: _language.code,
          tokenTimestamps: false,
        ),
      );
      cancel?.onCancel(task.cancel);
      final result = await task.result;
      return Result.success([
        // High no-speech probability = music/silence the model hallucinated over.
        for (final s in result.segments)
          if (s.noSpeechProbability < _maxNoSpeech)
            TranscriptSegment(start: s.start, end: s.end, text: s.text),
      ]);
    } on WhisperException catch (e) {
      if (cancel?.isCancelled ?? false) {
        return const Result.failure(CancelledFailure());
      }
      return Result.failure(UnknownFailure(e.toString()));
    } on FileSystemException catch (e) {
      return Result.failure(StorageFailure(e.message));
    } finally {
      final f = File(wavPath);
      if (f.existsSync()) await f.delete();
    }
  }

  @override
  Future<void> dispose() async {
    _engine?.dispose();
    _engine = null;
  }
}
