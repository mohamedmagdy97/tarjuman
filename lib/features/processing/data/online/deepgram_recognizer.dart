import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/processing/data/online/online_http.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/entities/transcript_segment.dart';
import 'package:tarjuman/features/processing/domain/ports/speech_recognizer.dart';

/// Deepgram pre-recorded transcription. Utterances are used when present;
/// otherwise words are grouped by pauses / length so cues stay readable.
class DeepgramRecognizer implements SpeechRecognizer {
  DeepgramRecognizer({
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
        final uri = Uri.parse('$baseUrl/listen').replace(
          queryParameters: {
            'model': model,
            'language': language.code,
            'punctuate': 'true',
            'smart_format': 'true',
            'utterances': 'true',
          },
        );
        final res = await _client.post(
          uri,
          headers: {
            'Authorization': 'Token $apiKey',
            'Content-Type': 'audio/wav',
          },
          body: await File(wavPath).readAsBytes(),
        );
        if (res.statusCode != 200) {
          return Result<List<TranscriptSegment>>.failure(
            failureForStatus(res.statusCode),
          );
        }
        final json =
            jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        return Result.success(parse(json));
      }, Result<List<TranscriptSegment>>.failure);
    } finally {
      final f = File(wavPath);
      if (f.existsSync()) await f.delete();
    }
  }

  /// Visible for tests.
  static List<TranscriptSegment> parse(Map<String, dynamic> json) {
    final results = json['results'] as Map<String, dynamic>? ?? {};
    final utterances = results['utterances'] as List<dynamic>?;
    if (utterances != null && utterances.isNotEmpty) {
      return [
        for (final u in utterances.cast<Map<String, dynamic>>())
          TranscriptSegment(
            start: _seconds(u['start']),
            end: _seconds(u['end']),
            text: (u['transcript'] as String? ?? '').trim(),
          ),
      ];
    }
    final channels = results['channels'] as List<dynamic>? ?? [];
    if (channels.isEmpty) return const [];
    final alts =
        (channels.first as Map<String, dynamic>)['alternatives']
            as List<dynamic>? ??
        [];
    if (alts.isEmpty) return const [];
    final words =
        ((alts.first as Map<String, dynamic>)['words'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
    return _group(words);
  }

  static List<TranscriptSegment> _group(List<Map<String, dynamic>> words) {
    const maxGap = 0.8;
    const maxLen = 7.0;
    final out = <TranscriptSegment>[];
    final buf = <String>[];
    double? start;
    double? last;
    void flush() {
      if (buf.isEmpty) return;
      out.add(
        TranscriptSegment(
          start: _seconds(start),
          end: _seconds(last),
          text: buf.join(' '),
        ),
      );
      buf.clear();
      start = null;
    }

    for (final w in words) {
      final ws = (w['start'] as num).toDouble();
      final we = (w['end'] as num).toDouble();
      final text = (w['punctuated_word'] ?? w['word']) as String;
      if (last != null && (ws - last > maxGap || we - (start ?? ws) > maxLen)) {
        flush();
      }
      start ??= ws;
      buf.add(text);
      last = we;
      if (RegExp(r'[.!?؟]$').hasMatch(text)) flush();
    }
    flush();
    return out;
  }

  static Duration _seconds(Object? v) =>
      Duration(milliseconds: (((v as num?) ?? 0) * 1000).round());

  @override
  Future<void> dispose() async => _client.close();
}
