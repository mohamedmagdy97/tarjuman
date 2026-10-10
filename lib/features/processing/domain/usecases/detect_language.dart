import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/ports/audio_extractor.dart';
import 'package:tarjuman/features/processing/domain/ports/language_detector.dart';

/// Listens to ~30 s from early in the video (skipping an intro jingle) and
/// reports which supported language is spoken.
class DetectLanguage {
  const DetectLanguage(this._audio, this._detector, this._workPath);

  final AudioExtractor _audio;
  final LanguageDetector _detector;
  final Future<String> Function(String name) _workPath;

  static const _sample = Duration(seconds: 30);

  Future<Result<SourceLanguage>> call({
    required String mediaPath,
    required Duration total,
  }) async {
    final start = total > const Duration(minutes: 2)
        ? Duration(milliseconds: total.inMilliseconds ~/ 10)
        : Duration.zero;
    final wav = await _workPath('detect.wav');
    final extracted = await _audio.extractWav(
      mediaPath: mediaPath,
      outPath: wav,
      start: start,
      length: _sample,
    );
    if (extracted case Err(:final failure)) return Result.failure(failure);

    final detected = await _detector.detect(wav);
    if (detected case Err(:final failure)) return Result.failure(failure);
    final code = (detected as Success<String>).value;
    final match = SourceLanguage.values.where((l) => l.code == code);
    return match.isEmpty
        ? Result.failure(UnsupportedLanguageFailure(code))
        : Result.success(match.first);
  }
}
