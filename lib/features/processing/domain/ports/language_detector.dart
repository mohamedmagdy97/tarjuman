import 'package:tarjuman/core/result/result.dart';

abstract interface class LanguageDetector {
  /// ISO 639-1 code of the language spoken in the 16 kHz mono WAV.
  Future<Result<String>> detect(String wavPath);
}
