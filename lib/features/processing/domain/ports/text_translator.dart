import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/result/result.dart';

abstract interface class TextTranslator {
  /// English -> Arabic. Output list matches [texts] one to one.
  Future<Result<List<String>>> translateBatch(
    List<String> texts, {
    CancelToken? cancel,
  });

  Future<void> dispose();
}
