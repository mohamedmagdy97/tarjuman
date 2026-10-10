import 'package:tarjuman/core/settings/settings_store.dart';
import 'package:tarjuman/features/processing/domain/entities/online_provider.dart';
import 'package:tarjuman/features/processing/domain/ports/online_config.dart';

/// [OnlineConfig] backed by the settings store and the keystore.
class SettingsOnlineConfig implements OnlineConfig {
  const SettingsOnlineConfig(this._settings, this._secrets);

  final SettingsStore _settings;
  final SecretStore _secrets;

  @override
  OnlineProvider get speechProvider => OnlineProvider.fromId(
    _settings.readSpeechProvider(),
    speech: true,
  );

  @override
  OnlineProvider get translationProvider => OnlineProvider.fromId(
    _settings.readTranslationProvider(),
    speech: false,
  );

  @override
  bool get consent => _settings.readOnlineConsent();

  @override
  Future<String?> key(OnlineProvider provider) async {
    final k = await _secrets.readApiKey(provider.id);
    return k == null || k.isEmpty ? null : k;
  }

  @override
  String model(OnlineProvider provider, {required bool speech}) {
    final custom = _settings.readOnlineModel(provider.id, speech: speech);
    if (custom.isNotEmpty) return custom;
    return speech ? provider.speechModel : provider.translationModel;
  }

  @override
  Future<bool> isReady() async {
    if (!consent) return false;
    for (final p in {speechProvider, translationProvider}) {
      if (p.needsKey && await key(p) == null) return false;
    }
    return true;
  }
}
