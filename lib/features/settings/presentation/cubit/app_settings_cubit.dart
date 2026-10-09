import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/core/settings/settings_store.dart';

class AppSettingsState extends Equatable {
  const AppSettingsState({
    this.themeMode = ThemeMode.dark,
    this.onlineConsent = false,
    this.hasApiKey = false,
  });

  final ThemeMode themeMode;
  final bool onlineConsent;
  final bool hasApiKey;

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    bool? onlineConsent,
    bool? hasApiKey,
  }) => AppSettingsState(
    themeMode: themeMode ?? this.themeMode,
    onlineConsent: onlineConsent ?? this.onlineConsent,
    hasApiKey: hasApiKey ?? this.hasApiKey,
  );

  @override
  List<Object?> get props => [themeMode, onlineConsent, hasApiKey];
}

/// App-wide settings; lives for the whole session (theme drives MaterialApp).
class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit(this._settings, this._secrets)
    : super(
        AppSettingsState(
          themeMode: _settings.readThemeMode(),
          onlineConsent: _settings.readOnlineConsent(),
        ),
      );

  final SettingsStore _settings;
  final SecretStore _secrets;

  Future<void> init() async {
    final key = await _secrets.readApiKey();
    emit(state.copyWith(hasApiKey: key != null && key.isNotEmpty));
  }

  Future<void> setTheme(ThemeMode m) async {
    emit(state.copyWith(themeMode: m));
    await _settings.writeThemeMode(m);
  }

  Future<void> setConsent({required bool value}) async {
    emit(state.copyWith(onlineConsent: value));
    await _settings.writeOnlineConsent(value: value);
  }

  Future<void> saveApiKey(String key) async {
    await _secrets.writeApiKey(key.trim());
    emit(state.copyWith(hasApiKey: key.trim().isNotEmpty));
  }
}
