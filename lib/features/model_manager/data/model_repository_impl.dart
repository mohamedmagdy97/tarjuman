import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:tarjuman/core/platform/device/device_capability.dart';
import 'package:tarjuman/features/model_manager/domain/entities/model_info.dart';
import 'package:tarjuman/features/model_manager/domain/repositories/model_repository.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:whisper_cpp_flutter_plus/whisper_cpp_flutter_plus.dart';

/// Speech models come from whisper_cpp_flutter_plus' checksum-pinned catalog;
/// translation models from the ML Kit on-device model manager.
class ModelRepositoryImpl implements ModelRepository {
  ModelRepositoryImpl(this._device)
    : _whisper = WhisperModelManager(),
      _mlkit = OnDeviceTranslatorModelManager();

  final DeviceCapability _device;
  final WhisperModelManager _whisper;
  final OnDeviceTranslatorModelManager _mlkit;

  // Devices with at least this much RAM get the larger model by default.
  static const _bigModelRamMb = 5500;
  static const _mlkitBytes = 30 * 1024 * 1024;

  static const _english = [
    WhisperModelCatalog.baseEnglish,
    WhisperModelCatalog.tinyEnglish,
  ];
  static const _multilingual = [
    WhisperModelCatalog.base,
    WhisperModelCatalog.tiny,
  ];
  static const _all = [..._english, ..._multilingual];

  WhisperModelDescriptor? _speechById(String id) =>
      _all.where((d) => d.id == id).firstOrNull;

  String? _languageOf(String id) =>
      id.startsWith('mlkit.') ? id.substring('mlkit.'.length) : null;

  Future<bool> _speechInstalled(WhisperModelDescriptor d) async {
    try {
      return await _whisper.findCatalogModel(d) != null;
    } on FormatException {
      return false; // checksum mismatch -> treat as not installed
    }
  }

  String _speechName(WhisperModelDescriptor d) {
    final size = d.id.startsWith('base') ? 'Base' : 'Tiny';
    return d.languageScope == WhisperModelLanguageScope.english
        ? '$size · English'
        : '$size · Multilingual';
  }

  @override
  Future<String> recommendedSpeechModelId(SourceLanguage language) async {
    final big = (await _device.ramMb() ?? 0) >= _bigModelRamMb;
    if (language.isEnglish) return big ? 'base.en' : 'tiny.en';
    return big ? 'base' : 'tiny';
  }

  @override
  Future<List<ModelInfo>> list() async {
    final recEn = await recommendedSpeechModelId(SourceLanguage.en);
    final recMulti = await recommendedSpeechModelId(SourceLanguage.fr);
    return [
      for (final d in _all)
        ModelInfo(
          id: d.id,
          kind: ModelKind.speech,
          name: _speechName(d),
          sizeBytes: d.approximateBytes,
          installed: await _speechInstalled(d),
          multilingual: d.languageScope != WhisperModelLanguageScope.english,
          recommended: d.id == recEn || d.id == recMulti,
        ),
      for (final l in [
        ...SourceLanguage.values,
      ])
        ModelInfo(
          id: 'mlkit.${l.code}',
          kind: ModelKind.translation,
          name: l.nativeName,
          sizeBytes: _mlkitBytes,
          installed: await _mlkit.isModelDownloaded(l.code),
          languageCode: l.code,
        ),
      ModelInfo(
        id: 'mlkit.ar',
        kind: ModelKind.translation,
        name: 'العربية',
        sizeBytes: _mlkitBytes,
        installed: await _mlkit.isModelDownloaded(
          TranslateLanguage.arabic.bcpCode,
        ),
        languageCode: 'ar',
      ),
    ];
  }

  @override
  Stream<double?> download(String id) async* {
    final speech = _speechById(id);
    if (speech != null) {
      await for (final p in _whisper.downloadCatalogModel(speech)) {
        yield p.fraction;
      }
      return;
    }
    final code = _languageOf(id);
    if (code == null) throw ArgumentError('Unknown model $id');
    yield null; // ML Kit gives no progress callbacks
    final ok = await _mlkit.downloadModel(code, isWifiRequired: false);
    if (!ok) throw StateError('Model download failed');
  }

  @override
  Future<void> remove(String id) async {
    final speech = _speechById(id);
    if (speech != null) return _whisper.delete(speech.fileName);
    final code = _languageOf(id);
    if (code != null) await _mlkit.deleteModel(code);
  }

  @override
  Future<String?> installedSpeechModelPath(SourceLanguage language) async {
    final rec = await recommendedSpeechModelId(language);
    // Preference: the recommended model first, then any other that can do it.
    final candidates = [
      ...(language.isEnglish ? _english : _multilingual),
      if (language.isEnglish) ..._multilingual,
    ]..sort((a, b) => (a.id == rec ? 0 : 1).compareTo(b.id == rec ? 0 : 1));
    for (final d in candidates) {
      try {
        final f = await _whisper.findCatalogModel(d);
        if (f != null) return f.path;
      } on FormatException {
        continue;
      }
    }
    return null;
  }

  @override
  Future<bool> translationReady(SourceLanguage language) async {
    for (final code in {language.code, TranslateLanguage.arabic.bcpCode}) {
      if (!await _mlkit.isModelDownloaded(code)) return false;
    }
    return true;
  }
}
