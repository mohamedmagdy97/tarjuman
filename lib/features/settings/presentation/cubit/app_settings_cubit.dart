import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/core/settings/settings_store.dart';
import 'package:tarjuman/features/processing/domain/entities/online_provider.dart';

class AppSettingsState extends Equatable {
  const AppSettingsState({
    this.themeMode = ThemeMode.dark,
    this.onlineConsent = false,
    this.autoSaveDownloads = false,
    this.speechProvider = OnlineProvider.groq,
    this.translationProvider = OnlineProvider.groq,
    this.providersWithKey = const {},
  });

  final ThemeMode themeMode;
  final bool onlineConsent;
  final bool autoSaveDownloads;
  final OnlineProvider speechProvider;
  final OnlineProvider translationProvider;
  final Set<OnlineProvider> providersWithKey;

  bool hasKey(OnlineProvider p) => !p.needsKey || providersWithKey.contains(p);

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    bool? onlineConsent,
    bool? autoSaveDownloads,
    OnlineProvider? speechProvider,
    OnlineProvider? translationProvider,
    Set<OnlineProvider>? providersWithKey,
  }) => AppSettingsState(
    themeMode: themeMode ?? this.themeMode,
    onlineConsent: onlineConsent ?? this.onlineConsent,
    autoSaveDownloads: autoSaveDownloads ?? this.autoSaveDownloads,
    speechProvider: speechProvider ?? this.speechProvider,
    translationProvider: translationProvider ?? this.translationProvider,
    providersWithKey: providersWithKey ?? this.providersWithKey,
  );

  @override
  List<Object?> get props => [
    themeMode,
    onlineConsent,
    autoSaveDownloads,
    speechProvider,
    translationProvider,
    providersWithKey,
  ];
}

/// App-wide settings; lives for the whole session (theme drives MaterialApp).
class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit(this._settings, this._secrets)
    : super(
        AppSettingsState(
          themeMode: _settings.readThemeMode(),
          onlineConsent: _settings.readOnlineConsent(),
          autoSaveDownloads: _settings.readAutoSaveDownloads(),
          speechProvider: OnlineProvider.fromId(
            _settings.readSpeechProvider(),
            speech: true,
          ),
          translationProvider: OnlineProvider.fromId(
            _settings.readTranslationProvider(),
            speech: false,
          ),
        ),
      );

  final SettingsStore _settings;
  final SecretStore _secrets;

  Future<void> init() async {
    final withKey = <OnlineProvider>{};
    for (final p in OnlineProvider.values) {
      final key = await _secrets.readApiKey(p.id);
      if (key != null && key.isNotEmpty) withKey.add(p);
    }
    emit(state.copyWith(providersWithKey: withKey));
  }

  Future<void> setTheme(ThemeMode m) async {
    emit(state.copyWith(themeMode: m));
    await _settings.writeThemeMode(m);
  }

  Future<void> setConsent({required bool value}) async {
    emit(state.copyWith(onlineConsent: value));
    await _settings.writeOnlineConsent(value: value);
  }

  Future<void> setAutoSave({required bool value}) async {
    emit(state.copyWith(autoSaveDownloads: value));
    await _settings.writeAutoSaveDownloads(value: value);
  }

  Future<void> setSpeechProvider(OnlineProvider p) async {
    emit(state.copyWith(speechProvider: p));
    await _settings.writeSpeechProvider(p.id);
  }

  Future<void> setTranslationProvider(OnlineProvider p) async {
    emit(state.copyWith(translationProvider: p));
    await _settings.writeTranslationProvider(p.id);
  }

  Future<void> saveApiKey(OnlineProvider p, String key) async {
    final trimmed = key.trim();
    await _secrets.writeApiKey(p.id, trimmed);
    final next = {...state.providersWithKey};
    trimmed.isEmpty ? next.remove(p) : next.add(p);
    emit(state.copyWith(providersWithKey: next));
  }

  String model(OnlineProvider p, {required bool speech}) =>
      _settings.readOnlineModel(p.id, speech: speech);

  Future<void> saveModel(
    OnlineProvider p, {
    required bool speech,
    required String model,
  }) => _settings.writeOnlineModel(p.id, speech: speech, model: model);
}
