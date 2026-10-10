import 'package:tarjuman/core/result/result.dart';

/// Translates a single word/phrase from the current source language to Arabic.
abstract interface class WordTranslator {
  Future<Result<String>> translate(String word);
}
