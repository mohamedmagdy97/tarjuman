import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/processing/domain/ports/text_translator.dart';

class MlKitTextTranslator implements TextTranslator {
  final OnDeviceTranslator _translator = OnDeviceTranslator(
    sourceLanguage: TranslateLanguage.english,
    targetLanguage: TranslateLanguage.arabic,
  );

  @override
  Future<Result<List<String>>> translateBatch(
    List<String> texts, {
    CancelToken? cancel,
  }) async {
    try {
      final out = <String>[];
      for (final t in texts) {
        if (cancel?.isCancelled ?? false) {
          return const Result.failure(CancelledFailure());
        }
        out.add(await _translator.translateText(t));
      }
      return Result.success(out);
    } on Exception catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<void> dispose() => _translator.close();
}
