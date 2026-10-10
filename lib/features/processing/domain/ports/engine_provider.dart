import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/ports/speech_recognizer.dart';
import 'package:tarjuman/features/processing/domain/ports/text_translator.dart';

class EngineSet {
  const EngineSet({required this.recognizer, required this.translator});
  final SpeechRecognizer recognizer;
  final TextTranslator translator;

  Future<void> dispose() async {
    await recognizer.dispose();
    await translator.dispose();
  }
}

/// Resolves the ASR + translator pair for an [EngineKind] and spoken
/// `language`, failing early (missing model / API key / consent) before any
/// heavy work starts.
abstract interface class EngineProvider {
  Future<Result<EngineSet>> acquire(
    EngineKind kind, {
    SourceLanguage language = SourceLanguage.en,
  });
}
