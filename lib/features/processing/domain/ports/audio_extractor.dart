import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/result/result.dart';

abstract interface class AudioExtractor {
  /// Total media duration, or failure if the file has no readable track.
  Future<Result<Duration>> probeDuration(String mediaPath);

  /// Writes 16 kHz mono PCM WAV for [start, start+length) to [outPath].
  Future<Result<String>> extractWav({
    required String mediaPath,
    required String outPath,
    required Duration start,
    required Duration length,
    CancelToken? cancel,
  });
}
