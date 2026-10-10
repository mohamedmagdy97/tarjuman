import 'package:flutter_test/flutter_test.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/ports/language_detector.dart';
import 'package:tarjuman/features/processing/domain/usecases/detect_language.dart';

import '../../../fakes/fakes.dart';

class _Detector implements LanguageDetector {
  _Detector(this.answer);
  final Result<String> answer;
  @override
  Future<Result<String>> detect(String wavPath) async => answer;
}

void main() {
  DetectLanguage build(FakeAudioExtractor audio, Result<String> answer) =>
      DetectLanguage(audio, _Detector(answer), (n) async => '/tmp/$n');

  test('maps a detected code to a supported language', () async {
    final audio = FakeAudioExtractor(const Duration(minutes: 20));
    final res = await build(audio, const Result.success('fr'))(
      mediaPath: '/v.mp4',
      total: const Duration(minutes: 20),
    );
    expect((res as Success<SourceLanguage>).value, SourceLanguage.fr);
    // Skips the first tenth of a long video (intro music).
    expect(audio.extracted.single, const Duration(minutes: 2));
  });

  test('short videos are sampled from the start', () async {
    final audio = FakeAudioExtractor(const Duration(seconds: 90));
    await build(audio, const Result.success('en'))(
      mediaPath: '/v.mp4',
      total: const Duration(seconds: 90),
    );
    expect(audio.extracted.single, Duration.zero);
  });

  test('an unsupported language is reported, not guessed', () async {
    final res = await build(
      FakeAudioExtractor(const Duration(minutes: 5)),
      const Result.success('ja'),
    )(mediaPath: '/v.mp4', total: const Duration(minutes: 5));
    expect(
      (res as Err<SourceLanguage>).failure,
      isA<UnsupportedLanguageFailure>(),
    );
  });

  test('detector failures (e.g. no multilingual model) pass through', () async {
    final res = await build(
      FakeAudioExtractor(const Duration(minutes: 5)),
      const Result.failure(ModelMissingFailure('multilingual')),
    )(mediaPath: '/v.mp4', total: const Duration(minutes: 5));
    expect((res as Err<SourceLanguage>).failure, isA<ModelMissingFailure>());
  });
}
