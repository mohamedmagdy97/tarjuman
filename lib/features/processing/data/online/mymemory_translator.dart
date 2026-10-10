import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/processing/data/online/online_http.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/ports/text_translator.dart';

/// MyMemory public API: no key, one line per request, tiny daily quota.
/// Meant for re-translating a line or two, not whole videos.
class MyMemoryTranslator implements TextTranslator {
  MyMemoryTranslator({
    this.baseUrl = 'https://api.mymemory.translated.net',
    this.language = SourceLanguage.en,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final SourceLanguage language;
  final http.Client _client;

  @override
  Future<Result<List<String>>> translateBatch(
    List<String> texts, {
    CancelToken? cancel,
  }) async {
    final out = <String>[];
    for (final text in texts) {
      if (cancel?.isCancelled ?? false) {
        return const Result.failure(CancelledFailure());
      }
      final res = await guardOnline(
        () => _one(text),
        Result<String>.failure,
      );
      if (res case Err(:final failure)) return Result.failure(failure);
      out.add((res as Success<String>).value);
    }
    return Result.success(out);
  }

  Future<Result<String>> _one(String text) async {
    final uri = Uri.parse('$baseUrl/get').replace(
      queryParameters: {'q': text, 'langpair': '${language.code}|ar'},
    );
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      return Result.failure(failureForStatus(res.statusCode));
    }
    final json = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final translated =
        (json['responseData'] as Map<String, dynamic>?)?['translatedText']
            as String?;
    if (translated == null || translated.isEmpty) {
      return const Result.failure(UnknownFailure('Empty translation'));
    }
    if (translated.toUpperCase().contains('MYMEMORY WARNING')) {
      return const Result.failure(RateLimitedFailure('MyMemory quota'));
    }
    return Result.success(translated);
  }

  @override
  Future<void> dispose() async => _client.close();
}
