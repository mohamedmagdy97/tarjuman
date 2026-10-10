import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/core/settings/settings_store.dart';
import 'package:tarjuman/features/glossary/domain/repositories/glossary_repository.dart';
import 'package:tarjuman/features/model_manager/domain/repositories/model_repository.dart';
import 'package:tarjuman/features/processing/data/glossary_text_translator.dart';
import 'package:tarjuman/features/processing/data/mlkit_text_translator.dart';
import 'package:tarjuman/features/processing/data/openai_online.dart';
import 'package:tarjuman/features/processing/data/whisper_speech_recognizer.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/ports/engine_provider.dart';

class EngineProviderImpl implements EngineProvider {
  EngineProviderImpl(
    this._models,
    this._settings,
    this._secrets,
    this._glossary,
  );

  final ModelRepository _models;
  final SettingsStore _settings;
  final SecretStore _secrets;
  final GlossaryRepository _glossary;

  @override
  Future<Result<EngineSet>> acquire(
    EngineKind kind, {
    SourceLanguage language = SourceLanguage.en,
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
              await _glossary.all(),
            ),
          ),
        );
      case EngineKind.online:
        final key = await _secrets.readApiKey();
        if (!_settings.readOnlineConsent() || key == null || key.isEmpty) {
          return const Result.failure(OnlineNotConfiguredFailure());
        }
        return Result.success(
          EngineSet(
            recognizer: OnlineSpeechRecognizer(key, language: language),
            translator: GlossaryTextTranslator(
              OnlineTextTranslator(key, language: language),
              await _glossary.all(),
            ),
          ),
        );
    }
  }
}
