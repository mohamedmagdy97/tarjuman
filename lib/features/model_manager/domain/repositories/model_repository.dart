import 'package:tarjuman/features/model_manager/domain/entities/model_info.dart';

abstract interface class ModelRepository {
  Future<List<ModelInfo>> list();

  /// Emits 0..1 progress, or null when the source can't report progress.
  /// Completes when installed; errors on failure.
  Stream<double?> download(String id);

  Future<void> remove(String id);

  /// Best installed speech model, or null if none.
  Future<String?> installedSpeechModelPath();

  Future<bool> translationReady();
}
