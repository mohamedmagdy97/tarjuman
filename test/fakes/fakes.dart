import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/entities/transcript_segment.dart';
import 'package:tarjuman/features/processing/domain/ports/audio_extractor.dart';
import 'package:tarjuman/features/processing/domain/ports/engine_provider.dart';
import 'package:tarjuman/features/processing/domain/ports/speech_recognizer.dart';
import 'package:tarjuman/features/processing/domain/ports/text_translator.dart';

class FakeAudioExtractor implements AudioExtractor {
  FakeAudioExtractor(this.total);
  final Duration total;
  final extracted = <Duration>[];

  @override
  Future<Result<Duration>> probeDuration(String mediaPath) async =>
      Result.success(total);

  @override
  Future<Result<String>> extractWav({
    required String mediaPath,
    required String outPath,
    required Duration start,
    required Duration length,
    CancelToken? cancel,
  }) async {
    extracted.add(start);
    return Result.success(outPath);
  }
}

/// Emits one 2 s sentence at the start of every range it is given.
class FakeRecognizer implements SpeechRecognizer {
  FakeRecognizer({this.failOnCall});
  final int? failOnCall;
  int calls = 0;
  bool disposed = false;

  @override
  Future<Result<List<TranscriptSegment>>> transcribe(
    String wavPath, {
    CancelToken? cancel,
  }) async {
    calls++;
    if (calls == failOnCall) {
      return const Result.failure(UnknownFailure('boom'));
    }
    return const Result.success([
      TranscriptSegment(
        start: Duration.zero,
        end: Duration(seconds: 2),
        text: 'Hello.',
      ),
    ]);
  }

  @override
  Future<void> dispose() async => disposed = true;
}

class FakeTranslator implements TextTranslator {
  @override
  Future<Result<List<String>>> translateBatch(
    List<String> texts, {
    CancelToken? cancel,
  }) async => Result.success([for (final t in texts) 'ar:$t']);

  @override
  Future<void> dispose() async {}
}

class FakeEngineProvider implements EngineProvider {
  FakeEngineProvider(this.recognizer, {this.failure});
  final FakeRecognizer recognizer;
  final Failure? failure;

  @override
  Future<Result<EngineSet>> acquire(
    EngineKind kind, {
    SourceLanguage language = SourceLanguage.en,
  }) async => failure != null
      ? Result.failure(failure!)
      : Result.success(
          EngineSet(recognizer: recognizer, translator: FakeTranslator()),
        );

  @override
  Future<Result<TextTranslator>> acquireTranslator(
    SourceLanguage language,
  ) async => failure != null
      ? Result.failure(failure!)
      : Result.success(FakeTranslator());
}
