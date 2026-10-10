import 'package:flutter_tts/flutter_tts.dart';

/// Speaks a word/sentence with the phone's TTS voice (offline if installed).
abstract interface class Pronouncer {
  Future<void> speak(String text, {required String languageCode});
  Future<void> stop();
}

class FlutterTtsPronouncer implements Pronouncer {
  final FlutterTts _tts = FlutterTts();

  @override
  Future<void> speak(String text, {required String languageCode}) async {
    try {
      await _tts.stop();
      await _tts.setLanguage(_locale(languageCode));
      await _tts.setSpeechRate(0.45);
      await _tts.speak(text);
    } on Object {
      // No TTS engine: pronunciation is a nicety.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } on Object {
      // ignore: best effort, see speak()
    }
  }

  String _locale(String code) => switch (code) {
    'en' => 'en-US',
    'fr' => 'fr-FR',
    'es' => 'es-ES',
    'de' => 'de-DE',
    'it' => 'it-IT',
    'pt' => 'pt-PT',
    'tr' => 'tr-TR',
    'ru' => 'ru-RU',
    _ => code,
  };
}
