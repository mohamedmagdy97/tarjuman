import 'package:tarjuman/core/result/result.dart';

abstract interface class AudioConverter {
  /// Writes the audio track of [mediaPath] as an MP3 file at [outPath].
  Future<Result<String>> toMp3({
    required String mediaPath,
    required String outPath,
  });
}
