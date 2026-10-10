import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/ports/text_translator.dart';

class MlKitTextTranslator implements TextTranslator {
  MlKitTextTranslator(SourceLanguage language)
    : _translator = OnDeviceTranslator(
        sourceLanguage:
            BCP47Code.fromRawValue(language.code) ?? TranslateLanguage.english,
        targetLanguage: TranslateLanguage.arabic,
      );

  final OnDeviceTranslator _translator;

  @override
  Future<Result<List<String>>> translateBatch(
    List<String> texts, {
    CancelToken? cancel,
  }) async {
    try {
      final out = <String>[];
      // A few lines at a time: ML Kit handles concurrent requests, which
      // shortens long chunks without hammering the device.
      const parallel = 4;
      for (var i = 0; i < texts.length; i += parallel) {
        if (cancel?.isCancelled ?? false) {
          return const Result.failure(CancelledFailure());
        }
        final group = texts.sublist(i, (i + parallel).clamp(0, texts.length));
        out.addAll(await Future.wait(group.map(_translator.translateText)));
      }
      return Result.success(out);
    } on Exception catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<void> dispose() => _translator.close();
}
