import 'dart:io';

import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/model_manager/domain/repositories/model_repository.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/ports/language_detector.dart';
import 'package:whisper_cpp_flutter_plus/whisper_cpp_flutter_plus.dart';

/// Language ID needs a multilingual Whisper model (the English-only ones
/// can't tell languages apart).
class WhisperLanguageDetector implements LanguageDetector {
  WhisperLanguageDetector(this._models);
  final ModelRepository _models;

  @override
  Future<Result<String>> detect(String wavPath) async {
    // Any non-English language resolves to the multilingual model list.
    final modelPath = await _models.installedSpeechModelPath(SourceLanguage.fr);
    if (modelPath == null) {
      return const Result.failure(ModelMissingFailure('multilingual'));
    }
    WhisperEngine? engine;
    try {
      engine = await WhisperEngine.load(modelPath);
      final samples = await WhisperAudio.readWav(File(wavPath));
      final result = await engine
          .transcribe(
            samples,
            options: const TranscribeOptions(
              detectLanguage: true,
              tokenTimestamps: false,
            ),
          )
          .result;
      final code = result.language.trim().toLowerCase();
      return code.isEmpty
          ? const Result.failure(UnknownFailure('No language detected'))
          : Result.success(code);
    } on WhisperException catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    } on FileSystemException catch (e) {
      return Result.failure(StorageFailure(e.message));
    } finally {
      engine?.dispose();
      final f = File(wavPath);
      if (f.existsSync()) await f.delete();
    }
  }
}
