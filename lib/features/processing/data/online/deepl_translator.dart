import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/processing/data/online/online_http.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/ports/text_translator.dart';

/// DeepL REST API. Free-plan keys end with `:fx` and use a different host.
class DeepLTranslator implements TextTranslator {
  DeepLTranslator({
    required this.apiKey,
    this.language = SourceLanguage.en,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String apiKey;
  final SourceLanguage language;
  final http.Client _client;
  static const _batch = 50;

  String get _host => apiKey.endsWith(':fx')
      ? 'https://api-free.deepl.com/v2'
      : 'https://api.deepl.com/v2';

  @override
  Future<Result<List<String>>> translateBatch(
    List<String> texts, {
    CancelToken? cancel,
  }) async {
    final out = <String>[];
    for (var i = 0; i < texts.length; i += _batch) {
      if (cancel?.isCancelled ?? false) {
        return const Result.failure(CancelledFailure());
      }
      final part = texts.sublist(i, (i + _batch).clamp(0, texts.length));
      final res = await guardOnline(
        () => _translate(part),
        Result<List<String>>.failure,
      );
      if (res case Err(:final failure)) return Result.failure(failure);
      out.addAll((res as Success<List<String>>).value);
    }
    return Result.success(out);
  }

  Future<Result<List<String>>> _translate(List<String> lines) async {
    final res = await _client.post(
      Uri.parse('$_host/translate'),
      headers: {
        'Authorization': 'DeepL-Auth-Key $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text': lines,
        'source_lang': language.code.toUpperCase(),
        'target_lang': 'AR',
      }),
    );
    if (res.statusCode != 200) {
      return Result.failure(failureForStatus(res.statusCode));
    }
    final list =
        (jsonDecode(utf8.decode(res.bodyBytes))
                as Map<String, dynamic>)['translations']
            as List<dynamic>? ??
        [];
    final out = [
      for (final t in list.cast<Map<String, dynamic>>()) t['text'] as String,
    ];
    return out.length == lines.length
        ? Result.success(out)
        : const Result.failure(UnknownFailure('Translation size mismatch'));
  }

  @override
  Future<void> dispose() async => _client.close();
}
