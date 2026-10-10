import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/core/settings/settings_store.dart';
import 'package:tarjuman/features/vocabulary/domain/ports/word_translator.dart';

class MlKitWordTranslator implements WordTranslator {
  MlKitWordTranslator(this._settings);
  final SettingsStore _settings;

  final _models = OnDeviceTranslatorModelManager();
  final _translators = <String, OnDeviceTranslator>{};

  @override
  Future<Result<String>> translate(String word) async {
    final code = _settings.readSourceLanguage();
    final source = BCP47Code.fromRawValue(code);
    if (source == null) return const Result.failure(UnknownFailure());
    try {
      if (!await _models.isModelDownloaded(source.bcpCode) ||
          !await _models.isModelDownloaded(TranslateLanguage.arabic.bcpCode)) {
        return const Result.failure(ModelMissingFailure('translation'));
      }
      final t = _translators.putIfAbsent(
        code,
        () => OnDeviceTranslator(
          sourceLanguage: source,
          targetLanguage: TranslateLanguage.arabic,
        ),
      );
      return Result.success(await t.translateText(word));
    } on Exception catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }
}
