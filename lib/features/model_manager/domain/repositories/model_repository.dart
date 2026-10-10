import 'package:tarjuman/features/model_manager/domain/entities/model_info.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';

abstract interface class ModelRepository {
  Future<List<ModelInfo>> list();

  /// Emits 0..1 progress, or null when the source can't report progress.
  /// Completes when installed; errors on failure.
  Stream<double?> download(String id);

  Future<void> remove(String id);

  /// Best installed speech model able to recognise [language], or null.
  Future<String?> installedSpeechModelPath(SourceLanguage language);

  /// Source-language + Arabic translation models are both installed.
  Future<bool> translationReady(SourceLanguage language);

  /// Id of the speech model that suits this device for [language].
  Future<String> recommendedSpeechModelId(SourceLanguage language);
}
