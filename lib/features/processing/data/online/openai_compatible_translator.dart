import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/processing/data/online/online_http.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/ports/text_translator.dart';

/// Chat-model translation for any OpenAI-compatible `/chat/completions`
/// endpoint (OpenAI, Groq, Gemini, OpenRouter). Keeps line count 1:1.
class OpenAiCompatibleTranslator implements TextTranslator {
  OpenAiCompatibleTranslator({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
    this.language = SourceLanguage.en,
    this.jsonMode = false,
    this.extraHeaders = const {},
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final String apiKey;
  final String model;
  final SourceLanguage language;

  /// Send `response_format: json_object` (not every provider accepts it).
  final bool jsonMode;
  final Map<String, String> extraHeaders;
  final http.Client _client;
  static const _batch = 25;

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
      Uri.parse('$baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        ...extraHeaders,
      },
      body: jsonEncode({
        'model': model,
        'temperature': 0,
        if (jsonMode) 'response_format': {'type': 'json_object'},
        'messages': [
          {
            'role': 'system',
            'content':
                'Translate each ${language.nativeName} subtitle line to '
                'natural Modern Standard Arabic. Keep the meaning, keep it '
                'short. Reply with JSON only: {"translations": [...]} with '
                'exactly the same number of items, in the same order.',
          },
          {'role': 'user', 'content': jsonEncode(lines)},
        ],
      }),
    );
    if (res.statusCode != 200) {
      return Result.failure(failureForStatus(res.statusCode));
    }
    final choices =
        (jsonDecode(utf8.decode(res.bodyBytes))
                as Map<String, dynamic>)['choices']
            as List<dynamic>?;
    final content = choices?.isNotEmpty ?? false
        ? (choices!.first as Map<String, dynamic>)['message']['content']
              as String?
        : null;
    final list = content == null ? null : parseTranslations(content);
    return list != null && list.length == lines.length
        ? Result.success(list)
        : const Result.failure(UnknownFailure('Translation size mismatch'));
  }

  /// Tolerant parse: models sometimes wrap JSON in prose or code fences, or
  /// return a bare array. Visible for tests.
  static List<String>? parseTranslations(String content) {
    final text = content.replaceAll(RegExp('```(?:json)?'), '');
    final start = text.indexOf(RegExp('[{[]'));
    final end = text.lastIndexOf(RegExp(r'[}\]]'));
    if (start < 0 || end <= start) return null;
    try {
      final decoded = jsonDecode(text.substring(start, end + 1));
      final list = decoded is Map<String, dynamic>
          ? decoded['translations']
          : decoded;
      if (list is! List) return null;
      return [for (final e in list) e.toString()];
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> dispose() async => _client.close();
}
