import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/glossary/domain/repositories/glossary_repository.dart';
import 'package:tarjuman/features/model_manager/domain/repositories/model_repository.dart';
import 'package:tarjuman/features/processing/data/glossary_text_translator.dart';
import 'package:tarjuman/features/processing/data/mlkit_text_translator.dart';
import 'package:tarjuman/features/processing/data/online/online_engines.dart';
import 'package:tarjuman/features/processing/data/whisper_speech_recognizer.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/ports/engine_provider.dart';
import 'package:tarjuman/features/processing/domain/ports/speech_recognizer.dart';
import 'package:tarjuman/features/processing/domain/ports/text_translator.dart';

class EngineProviderImpl implements EngineProvider {
  EngineProviderImpl(this._models, this._online, this._glossary);

  final ModelRepository _models;
  final OnlineEngines _online;
  final GlossaryRepository _glossary;

  @override
  Future<Result<TextTranslator>> acquireTranslator(
    SourceLanguage language, {
    String? videoId,
  }) async {
    final res = await _online.translator(language);
    return switch (res) {
      Success(:final value) => Result.success(
        GlossaryTextTranslator(
          value,
          await _glossary.effective(videoId: videoId),
        ),
      ),
      Err(:final failure) => Result.failure(failure),
    };
  }

  @override
  Future<Result<EngineSet>> acquire(
    EngineKind kind, {
    SourceLanguage language = SourceLanguage.en,
    String? videoId,
  }) async {
    switch (kind) {
      case EngineKind.offline:
        if (await _models.installedSpeechModelPath(language) == null) {
          return const Result.failure(ModelMissingFailure('speech'));
        }
        if (!await _models.translationReady(language)) {
          return const Result.failure(ModelMissingFailure('translation'));
        }
        return Result.success(
          EngineSet(
            recognizer: WhisperSpeechRecognizer(_models, language),
            translator: GlossaryTextTranslator(
              MlKitTextTranslator(language),
              await _glossary.effective(videoId: videoId),
            ),
          ),
        );
      case EngineKind.online:
        final recognizer = await _online.recognizer(language);
        if (recognizer case Err(:final failure)) {
          return Result.failure(failure);
        }
        final translator = await acquireTranslator(
          language,
          videoId: videoId,
        );
        if (translator case Err(:final failure)) {
          await (recognizer as Success<SpeechRecognizer>).value.dispose();
          return Result.failure(failure);
        }
        return Result.success(
          EngineSet(
            recognizer: (recognizer as Success<SpeechRecognizer>).value,
            translator: (translator as Success<TextTranslator>).value,
          ),
        );
    }
  }
}
