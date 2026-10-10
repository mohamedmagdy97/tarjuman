import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/processing/data/online/deepgram_recognizer.dart';
import 'package:tarjuman/features/processing/data/online/deepl_translator.dart';
import 'package:tarjuman/features/processing/data/online/mymemory_translator.dart';
import 'package:tarjuman/features/processing/data/online/online_engines.dart';
import 'package:tarjuman/features/processing/data/online/openai_compatible_recognizer.dart';
import 'package:tarjuman/features/processing/data/online/openai_compatible_translator.dart';
import 'package:tarjuman/features/processing/domain/entities/online_provider.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/ports/online_config.dart';

http.Response _json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

OpenAiCompatibleTranslator _chat(MockClient c, {bool jsonMode = true}) =>
    OpenAiCompatibleTranslator(
      baseUrl: 'https://x/v1',
      apiKey: 'k',
      model: 'm',
      jsonMode: jsonMode,
      client: c,
    );

Map<String, dynamic> _chatReply(String content) => {
  'choices': [
    {
      'message': {'content': content},
    },
  ],
};

void main() {
  group('OpenAiCompatibleTranslator', () {
    test('parses plain JSON and sends json_object only when asked', () async {
      late Map<String, dynamic> sent;
      final t = _chat(
        MockClient((r) async {
          sent = jsonDecode(r.body) as Map<String, dynamic>;
          return _json(_chatReply('{"translations":["أ","ب"]}'));
        }),
      );
      final res = await t.translateBatch(['a', 'b']);
      expect((res as Success<List<String>>).value, ['أ', 'ب']);
      expect(sent['response_format'], isNotNull);

      final noJson = _chat(
        MockClient((r) async {
          sent = jsonDecode(r.body) as Map<String, dynamic>;
          return _json(_chatReply('["أ"]'));
        }),
        jsonMode: false,
      );
      await noJson.translateBatch(['a']);
      expect(sent.containsKey('response_format'), isFalse);
    });

    test('tolerates code fences, prose and bare arrays', () {
      expect(
        OpenAiCompatibleTranslator.parseTranslations(
          'Sure!\n```json\n{"translations": ["x", "y"]}\n```',
        ),
        ['x', 'y'],
      );
      expect(OpenAiCompatibleTranslator.parseTranslations('["x"]'), ['x']);
      expect(OpenAiCompatibleTranslator.parseTranslations('no json'), isNull);
    });

    test('line count mismatch is a failure, not silent misalignment', () async {
      final t = _chat(
        MockClient((_) async => _json(_chatReply('{"translations":["أ"]}'))),
      );
      expect(await t.translateBatch(['a', 'b']), isA<Err<List<String>>>());
    });

    test('maps 401 to not-configured and 429 to rate-limited', () async {
      Future<Failure> failFor(int status) async {
        final res = await _chat(
          MockClient((_) async => _json({}, status)),
        ).translateBatch(['a']);
        return (res as Err<List<String>>).failure;
      }

      expect(await failFor(401), isA<OnlineNotConfiguredFailure>());
      expect(await failFor(429), isA<RateLimitedFailure>());
      expect(await failFor(500), isA<NetworkFailure>());
    });
  });

  group('DeepLTranslator', () {
    test(
      'uses the free host for :fx keys and uppercase language codes',
      () async {
        late http.Request req;
        final t = DeepLTranslator(
          apiKey: 'abc:fx',
          language: SourceLanguage.fr,
          client: MockClient((r) async {
            req = r;
            return _json({
              'translations': [
                {'text': 'مرحبا'},
              ],
            });
          }),
        );
        final res = await t.translateBatch(['bonjour']);
        expect((res as Success<List<String>>).value, ['مرحبا']);
        expect(req.url.host, 'api-free.deepl.com');
        expect(req.headers['Authorization'], 'DeepL-Auth-Key abc:fx');
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        expect(body['source_lang'], 'FR');
        expect(body['target_lang'], 'AR');
      },
    );

    test('456 (quota exceeded) is rate-limited', () async {
      final t = DeepLTranslator(
        apiKey: 'k',
        client: MockClient((_) async => _json({}, 456)),
      );
      final res = await t.translateBatch(['a']);
      expect((res as Err<List<String>>).failure, isA<RateLimitedFailure>());
    });
  });

  group('MyMemoryTranslator', () {
    test('translates line by line and detects the quota warning', () async {
      var n = 0;
      final t = MyMemoryTranslator(
        client: MockClient((r) async {
          n++;
          expect(r.url.queryParameters['langpair'], 'en|ar');
          return _json({
            'responseData': {'translatedText': 'ar$n'},
          });
        }),
      );
      final res = await t.translateBatch(['a', 'b']);
      expect((res as Success<List<String>>).value, ['ar1', 'ar2']);

      final limited = MyMemoryTranslator(
        client: MockClient(
          (_) async => _json({
            'responseData': {
              'translatedText': 'MYMEMORY WARNING: YOU USED ALL',
            },
          }),
        ),
      );
      final bad = await limited.translateBatch(['a']);
      expect((bad as Err<List<String>>).failure, isA<RateLimitedFailure>());
    });
  });

  group('Recognizers', () {
    late File wav;
    setUp(() {
      wav = File('${Directory.systemTemp.path}/tarjuman_test_online.wav')
        ..writeAsBytesSync([0, 1, 2, 3]);
    });
    tearDown(() {
      if (wav.existsSync()) wav.deleteSync();
    });

    test('OpenAI-compatible parses verbose_json segments', () async {
      final r = OpenAiCompatibleRecognizer(
        baseUrl: 'https://x/v1',
        apiKey: 'k',
        model: 'm',
        client: MockClient(
          (_) async => _json({
            'segments': [
              {'start': 0.0, 'end': 1.5, 'text': ' Hello.'},
            ],
          }),
        ),
      );
      final res = await r.transcribe(wav.path);
      final segs = (res as Success<List>).value;
      expect(segs.single.text, 'Hello.');
      expect(segs.single.end, const Duration(milliseconds: 1500));
      expect(wav.existsSync(), isFalse);
    });

    test('Deepgram prefers utterances', () {
      final segs = DeepgramRecognizer.parse({
        'results': {
          'utterances': [
            {'start': 1.0, 'end': 2.0, 'transcript': 'Hi there.'},
          ],
        },
      });
      expect(segs.single.start, const Duration(seconds: 1));
      expect(segs.single.text, 'Hi there.');
    });

    test('Deepgram falls back to grouping words by pauses', () {
      Map<String, dynamic> w(String t, double s, double e) => {
        'word': t,
        'punctuated_word': t,
        'start': s,
        'end': e,
      };
      final segs = DeepgramRecognizer.parse({
        'results': {
          'channels': [
            {
              'alternatives': [
                {
                  'words': [
                    w('Hello', 0, 0.4),
                    w('world.', 0.5, 0.9),
                    w('Next', 3, 3.3),
                    w('one', 3.4, 3.7),
                  ],
                },
              ],
            },
          ],
        },
      });
      expect(segs.map((s) => s.text), ['Hello world.', 'Next one']);
    });

    test('Deepgram sends the Token header and wav bytes', () async {
      late http.Request req;
      final r = DeepgramRecognizer(
        baseUrl: 'https://api.deepgram.com/v1',
        apiKey: 'dg',
        model: 'nova-3',
        language: SourceLanguage.de,
        client: MockClient((q) async {
          req = q;
          return _json({'results': <String, dynamic>{}});
        }),
      );
      await r.transcribe(wav.path);
      expect(req.headers['Authorization'], 'Token dg');
      expect(req.url.queryParameters['language'], 'de');
      expect(req.bodyBytes, [0, 1, 2, 3]);
    });
  });

  group('OnlineEngines', () {
    test(
      'fails fast without consent or key; builds the chosen providers',
      () async {
        final cfg = _Cfg();
        final engines = OnlineEngines(cfg);
        expect(
          (await engines.translator(SourceLanguage.en) as Err<dynamic>).failure,
          isA<OnlineNotConfiguredFailure>(),
        );
        cfg
          ..consent = true
          ..keys['groq'] = 'gk';
        final t = await engines.translator(SourceLanguage.en);
        expect(t, isA<Success<dynamic>>());
        cfg.translation = OnlineProvider.mymemory;
        expect(
          (await engines.translator(SourceLanguage.en) as Success<dynamic>)
              .value,
          isA<MyMemoryTranslator>(),
        );
        cfg.speech = OnlineProvider.deepgram;
        expect(
          await engines.recognizer(SourceLanguage.en),
          isA<Err<dynamic>>(),
        );
        cfg.keys['deepgram'] = 'dk';
        expect(
          (await engines.recognizer(SourceLanguage.en) as Success<dynamic>)
              .value,
          isA<DeepgramRecognizer>(),
        );
      },
    );
  });
}

class _Cfg implements OnlineConfig {
  @override
  bool consent = false;
  OnlineProvider speech = OnlineProvider.groq;
  OnlineProvider translation = OnlineProvider.groq;
  final keys = <String, String>{};

  @override
  OnlineProvider get speechProvider => speech;
  @override
  OnlineProvider get translationProvider => translation;
  @override
  Future<String?> key(OnlineProvider p) async => keys[p.id];
  @override
  String model(OnlineProvider p, {required bool speech}) =>
      speech ? p.speechModel : p.translationModel;
  @override
  Future<bool> isReady() async => consent;
}
