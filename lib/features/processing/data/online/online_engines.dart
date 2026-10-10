import 'package:http/http.dart' as http;
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/processing/data/online/deepgram_recognizer.dart';
import 'package:tarjuman/features/processing/data/online/deepl_translator.dart';
import 'package:tarjuman/features/processing/data/online/mymemory_translator.dart';
import 'package:tarjuman/features/processing/data/online/openai_compatible_recognizer.dart';
import 'package:tarjuman/features/processing/data/online/openai_compatible_translator.dart';
import 'package:tarjuman/features/processing/domain/entities/online_provider.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/ports/online_config.dart';
import 'package:tarjuman/features/processing/domain/ports/speech_recognizer.dart';
import 'package:tarjuman/features/processing/domain/ports/text_translator.dart';

/// Builds the cloud recognizer / translator the user picked, failing early
/// when consent or a key is missing.
class OnlineEngines {
  OnlineEngines(this._config, {http.Client Function()? client})
    : _client = client;

  final OnlineConfig _config;
  final http.Client Function()? _client;

  http.Client? get _c => _client?.call();

  Future<Result<SpeechRecognizer>> recognizer(SourceLanguage language) async {
    if (!_config.consent) {
      return const Result.failure(OnlineNotConfiguredFailure());
    }
    final p = _config.speechProvider;
    final key = await _config.key(p);
    if (key == null) return const Result.failure(OnlineNotConfiguredFailure());
    final model = _config.model(p, speech: true);
    return Result.success(switch (p) {
      OnlineProvider.deepgram => DeepgramRecognizer(
        baseUrl: p.baseUrl,
        apiKey: key,
        model: model,
        language: language,
        client: _c,
      ),
      _ => OpenAiCompatibleRecognizer(
        baseUrl: p.baseUrl,
        apiKey: key,
        model: model,
        language: language,
        client: _c,
      ),
    });
  }

  Future<Result<TextTranslator>> translator(SourceLanguage language) async {
    if (!_config.consent) {
      return const Result.failure(OnlineNotConfiguredFailure());
    }
    final p = _config.translationProvider;
    final key = p.needsKey ? await _config.key(p) : '';
    if (key == null) return const Result.failure(OnlineNotConfiguredFailure());
    final model = _config.model(p, speech: false);
    return Result.success(switch (p) {
      OnlineProvider.deepl => DeepLTranslator(
        apiKey: key,
        language: language,
        client: _c,
      ),
      OnlineProvider.mymemory => MyMemoryTranslator(
        language: language,
        client: _c,
      ),
      _ => OpenAiCompatibleTranslator(
        baseUrl: p.baseUrl,
        apiKey: key,
        model: model,
        language: language,
        jsonMode: p.jsonMode,
        client: _c,
      ),
    });
  }
}
