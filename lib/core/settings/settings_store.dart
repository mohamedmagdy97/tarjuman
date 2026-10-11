import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_style.dart';

abstract interface class SettingsStore {
  SubtitleStyle readSubtitleStyle();
  Future<void> writeSubtitleStyle(SubtitleStyle style);

  ThemeMode readThemeMode();
  Future<void> writeThemeMode(ThemeMode mode);

  bool readAutoSaveDownloads();
  Future<void> writeAutoSaveDownloads({required bool value});

  bool readOnlineConsent();
  Future<void> writeOnlineConsent({required bool value});

  /// Per-video subtitle shift (positive = later).
  Duration readSubtitleOffset(String videoId);
  Future<void> writeSubtitleOffset(String videoId, Duration offset);

  /// Online providers (ids from `OnlineProvider`).
  String readSpeechProvider();
  Future<void> writeSpeechProvider(String id);
  String readTranslationProvider();
  Future<void> writeTranslationProvider(String id);

  /// Optional model-name override for a provider ('' = default).
  String readOnlineModel(String providerId, {required bool speech});
  Future<void> writeOnlineModel(
    String providerId, {
    required bool speech,
    required String model,
  });

  bool readOnboardingDone();
  Future<void> writeOnboardingDone();

  /// ISO code of the spoken language to recognise, default `en`.
  String readSourceLanguage();
  Future<void> writeSourceLanguage(String code);
}

/// API keys live in the platform keystore, never in shared preferences.
abstract interface class SecretStore {
  Future<String?> readApiKey(String provider);
  Future<void> writeApiKey(String provider, String? key);
}

class KeystoreSecretStore implements SecretStore {
  const KeystoreSecretStore([
    this._storage = const FlutterSecureStorage(),
  ]);
  final FlutterSecureStorage _storage;

  // The first release stored the OpenAI key under this name; keep it.
  String _name(String provider) =>
      provider == 'openai' ? 'online.api_key' : 'online.api_key.$provider';

  @override
  Future<String?> readApiKey(String provider) =>
      _storage.read(key: _name(provider));

  @override
  Future<void> writeApiKey(String provider, String? key) =>
      key == null || key.isEmpty
      ? _storage.delete(key: _name(provider))
      : _storage.write(key: _name(provider), value: key);
}

class SharedPrefsSettingsStore implements SettingsStore {
  SharedPrefsSettingsStore(this._prefs);
  final SharedPreferences _prefs;

  static const _size = 'subtitle.size';
  static const _color = 'subtitle.color';
  static const _bg = 'subtitle.background';
  static const _pos = 'subtitle.position';
  static const _orig = 'subtitle.original';
  static const _theme = 'app.theme';
  static const _consent = 'online.consent';

  @override
  SubtitleStyle readSubtitleStyle() {
    T pick<T extends Enum>(List<T> values, String key, T fallback) {
      final name = _prefs.getString(key);
      return values.asNameMap()[name] ?? fallback;
    }

    return SubtitleStyle(
      fontSize: _prefs.getDouble(_size) ?? 22,
      color: pick(
        SubtitleColorPreset.values,
        _color,
        SubtitleColorPreset.white,
      ),
      background: pick(SubtitleBackground.values, _bg, SubtitleBackground.box),
      position: pick(SubtitlePosition.values, _pos, SubtitlePosition.bottom),
      showOriginal: _prefs.getBool(_orig) ?? false,
    );
  }

  @override
  Future<void> writeSubtitleStyle(SubtitleStyle s) async {
    await _prefs.setDouble(_size, s.fontSize);
    await _prefs.setString(_color, s.color.name);
    await _prefs.setString(_bg, s.background.name);
    await _prefs.setString(_pos, s.position.name);
    await _prefs.setBool(_orig, s.showOriginal);
  }

  @override
  ThemeMode readThemeMode() =>
      ThemeMode.values.asNameMap()[_prefs.getString(_theme)] ?? ThemeMode.dark;

  @override
  Future<void> writeThemeMode(ThemeMode mode) =>
      _prefs.setString(_theme, mode.name);

  @override
  bool readAutoSaveDownloads() => _prefs.getBool('downloads.autosave') ?? false;

  @override
  Future<void> writeAutoSaveDownloads({required bool value}) =>
      _prefs.setBool('downloads.autosave', value);

  @override
  bool readOnlineConsent() => _prefs.getBool(_consent) ?? false;

  @override
  Future<void> writeOnlineConsent({required bool value}) =>
      _prefs.setBool(_consent, value);

  @override
  Duration readSubtitleOffset(String videoId) =>
      Duration(milliseconds: _prefs.getInt('subtitle.offset.$videoId') ?? 0);

  @override
  Future<void> writeSubtitleOffset(String videoId, Duration offset) =>
      _prefs.setInt('subtitle.offset.$videoId', offset.inMilliseconds);

  @override
  String readSpeechProvider() => _prefs.getString('online.speech') ?? 'groq';

  @override
  Future<void> writeSpeechProvider(String id) =>
      _prefs.setString('online.speech', id);

  @override
  String readTranslationProvider() =>
      _prefs.getString('online.translation') ?? 'groq';

  @override
  Future<void> writeTranslationProvider(String id) =>
      _prefs.setString('online.translation', id);

  @override
  String readOnlineModel(String providerId, {required bool speech}) =>
      _prefs.getString('online.model.$providerId.${speech ? 's' : 't'}') ?? '';

  @override
  Future<void> writeOnlineModel(
    String providerId, {
    required bool speech,
    required String model,
  }) => _prefs.setString(
    'online.model.$providerId.${speech ? 's' : 't'}',
    model.trim(),
  );

  @override
  bool readOnboardingDone() => _prefs.getBool('app.onboarding') ?? false;

  @override
  Future<void> writeOnboardingDone() => _prefs.setBool('app.onboarding', true);

  @override
  String readSourceLanguage() => _prefs.getString('asr.language') ?? 'en';

  @override
  Future<void> writeSourceLanguage(String code) =>
      _prefs.setString('asr.language', code);
}
