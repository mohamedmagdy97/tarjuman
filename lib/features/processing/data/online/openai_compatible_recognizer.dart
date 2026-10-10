import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/processing/data/online/online_http.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/entities/transcript_segment.dart';
import 'package:tarjuman/features/processing/domain/ports/speech_recognizer.dart';

/// Cloud ASR for any `/audio/transcriptions` endpoint shaped like OpenAI's
/// (OpenAI, Groq). Audio leaves the device — only built after consent.
class OpenAiCompatibleRecognizer implements SpeechRecognizer {
  OpenAiCompatibleRecognizer({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
    this.language = SourceLanguage.en,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final String apiKey;
  final String model;
  final SourceLanguage language;
  final http.Client _client;

  @override
  Future<Result<List<TranscriptSegment>>> transcribe(
    String wavPath, {
    CancelToken? cancel,
  }) async {
    try {
      return await guardOnline(() async {
        final req =
            http.MultipartRequest(
                'POST',
                Uri.parse('$baseUrl/audio/transcriptions'),
              )
              ..headers['Authorization'] = 'Bearer $apiKey'
              ..fields['model'] = model
              ..fields['language'] = language.code
              ..fields['response_format'] = 'verbose_json'
              ..fields['timestamp_granularities[]'] = 'segment'
              ..files.add(await http.MultipartFile.fromPath('file', wavPath));
        final res = await http.Response.fromStream(await _client.send(req));
        if (res.statusCode != 200) {
          return Result<List<TranscriptSegment>>.failure(
            failureForStatus(res.statusCode),
          );
        }
        final json =
            jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final segments = (json['segments'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
        return Result.success([
          for (final s in segments)
            TranscriptSegment(
              start: _seconds(s['start']),
              end: _seconds(s['end']),
              text: (s['text'] as String? ?? '').trim(),
            ),
        ]);
      }, Result<List<TranscriptSegment>>.failure);
    } finally {
      final f = File(wavPath);
      if (f.existsSync()) await f.delete();
    }
  }

  static Duration _seconds(Object? v) =>
      Duration(milliseconds: (((v as num?) ?? 0) * 1000).round());

  @override
  Future<void> dispose() async => _client.close();
}
