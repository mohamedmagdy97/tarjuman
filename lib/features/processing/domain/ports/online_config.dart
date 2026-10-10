import 'package:tarjuman/features/processing/domain/entities/online_provider.dart';

/// The user's online-mode choices: consent, which provider does what, keys
/// and optional model-name overrides.
abstract interface class OnlineConfig {
  OnlineProvider get speechProvider;
  OnlineProvider get translationProvider;
  bool get consent;

  Future<String?> key(OnlineProvider provider);

  /// User-edited model name, or the provider default.
  String model(OnlineProvider provider, {required bool speech});

  /// Consent given and every selected provider has what it needs.
  Future<bool> isReady();
}
