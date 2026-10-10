import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/entities/transcript_segment.dart';
import 'package:tarjuman/features/processing/domain/ports/speech_recognizer.dart';
import 'package:tarjuman/features/processing/domain/ports/text_translator.dart';

const _base = 'https://api.openai.com/v1';

Failure _httpFailure(http.Response r) => r.statusCode == 401
    ? const OnlineNotConfiguredFailure('Invalid API key')
    : NetworkFailure('HTTP ${r.statusCode}');

/// Cloud ASR (OpenAI-compatible `/audio/transcriptions`). Audio leaves the
/// device — only constructed after explicit user consent.
class OnlineSpeechRecognizer implements SpeechRecognizer {
  OnlineSpeechRecognizer(
    this._apiKey, {
    this.language = SourceLanguage.en,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String _apiKey;
  final SourceLanguage language;
  final http.Client _client;
  static const model = 'whisper-1';

  @override
  Future<Result<List<TranscriptSegment>>> transcribe(
    String wavPath, {
    CancelToken? cancel,
  }) async {
    try {
      final req =
          http.MultipartRequest(
              'POST',
              Uri.parse('$_base/audio/transcriptions'),
            )
            ..headers['Authorization'] = 'Bearer $_apiKey'
            ..fields['model'] = model
            ..fields['language'] = language.code
            ..fields['response_format'] = 'verbose_json'
            ..fields['timestamp_granularities[]'] = 'segment'
            ..files.add(await http.MultipartFile.fromPath('file', wavPath));
      final res = await http.Response.fromStream(await _client.send(req));
      if (res.statusCode != 200) return Result.failure(_httpFailure(res));
      final json =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final segments = (json['segments'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      return Result.success([
        for (final s in segments)
          TranscriptSegment(
            start: Duration(milliseconds: ((s['start'] as num) * 1000).round()),
            end: Duration(milliseconds: ((s['end'] as num) * 1000).round()),
            text: s['text'] as String,
          ),
      ]);
    } on SocketException {
      return const Result.failure(NetworkFailure());
    } on http.ClientException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } finally {
      final f = File(wavPath);
      if (f.existsSync()) await f.delete();
    }
  }

  @override
  Future<void> dispose() async => _client.close();
}

/// Cloud translation through a chat model; keeps line count 1:1.
class OnlineTextTranslator implements TextTranslator {
  OnlineTextTranslator(
    this._apiKey, {
    this.language = SourceLanguage.en,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String _apiKey;
  final SourceLanguage language;
  final http.Client _client;
  static const model = 'gpt-4o-mini';
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
      final res = await _translate(part);
      if (res case Err(:final failure)) return Result.failure(failure);
      out.addAll((res as Success<List<String>>).value);
    }
    return Result.success(out);
  }

  Future<Result<List<String>>> _translate(List<String> lines) async {
    try {
      final res = await _client.post(
        Uri.parse('$_base/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'temperature': 0,
          'response_format': {'type': 'json_object'},
          'messages': [
            {
              'role': 'system',
              'content':
                  'Translate each ${language.nativeName} subtitle line to natural '
                  'Modern Standard Arabic. Keep meaning, keep it short. '
                  'Reply as JSON {"translations": [...]} with exactly the same '
                  'number of items, in order.',
            },
            {'role': 'user', 'content': jsonEncode(lines)},
          ],
        }),
      );
      if (res.statusCode != 200) return Result.failure(_httpFailure(res));
      final content =
          ((jsonDecode(utf8.decode(res.bodyBytes))
                          as Map<String, dynamic>)['choices']
                      as List<dynamic>)
                  .first['message']['content']
              as String;
      final list =
          ((jsonDecode(content) as Map<String, dynamic>)['translations']
                  as List<dynamic>)
              .cast<String>();
      return list.length == lines.length
          ? Result.success(list)
          : const Result.failure(UnknownFailure('Translation size mismatch'));
    } on SocketException {
      return const Result.failure(NetworkFailure());
    } on http.ClientException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on FormatException {
      return const Result.failure(UnknownFailure('Bad translation response'));
    }
  }

  @override
  Future<void> dispose() async => _client.close();
}
