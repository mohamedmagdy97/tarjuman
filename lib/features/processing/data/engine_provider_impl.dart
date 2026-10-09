import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/core/settings/settings_store.dart';
import 'package:tarjuman/features/model_manager/domain/repositories/model_repository.dart';
import 'package:tarjuman/features/processing/data/mlkit_text_translator.dart';
import 'package:tarjuman/features/processing/data/openai_online.dart';
import 'package:tarjuman/features/processing/data/whisper_speech_recognizer.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/domain/ports/engine_provider.dart';

class EngineProviderImpl implements EngineProvider {
  EngineProviderImpl(this._models, this._settings, this._secrets);

  final ModelRepository _models;
  final SettingsStore _settings;
  final SecretStore _secrets;

  @override
  Future<Result<EngineSet>> acquire(EngineKind kind) async {
    switch (kind) {
      case EngineKind.offline:
        if (await _models.installedSpeechModelPath() == null) {
          return const Result.failure(ModelMissingFailure('speech'));
        }
        if (!await _models.translationReady()) {
          return const Result.failure(ModelMissingFailure('translation'));
        }
        return Result.success(
          EngineSet(
            recognizer: WhisperSpeechRecognizer(_models),
            translator: MlKitTextTranslator(),
          ),
        );
      case EngineKind.online:
        final key = await _secrets.readApiKey();
        if (!_settings.readOnlineConsent() || key == null || key.isEmpty) {
          return const Result.failure(OnlineNotConfiguredFailure());
        }
        return Result.success(
          EngineSet(
            recognizer: OnlineSpeechRecognizer(key),
            translator: OnlineTextTranslator(key),
          ),
        );
    }
  }
}
