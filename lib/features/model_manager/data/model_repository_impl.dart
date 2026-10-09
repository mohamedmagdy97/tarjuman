import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:tarjuman/features/model_manager/domain/entities/model_info.dart';
import 'package:tarjuman/features/model_manager/domain/repositories/model_repository.dart';
import 'package:whisper_cpp_flutter_plus/whisper_cpp_flutter_plus.dart';

/// Speech models come from whisper_cpp_flutter_plus' checksum-pinned catalog;
/// translation models from the ML Kit on-device model manager.
class ModelRepositoryImpl implements ModelRepository {
  ModelRepositoryImpl()
    : _whisper = WhisperModelManager(),
      _mlkit = OnDeviceTranslatorModelManager();

  final WhisperModelManager _whisper;
  final OnDeviceTranslatorModelManager _mlkit;

  // English-only models: better accuracy/size for English speech. Preference order.
  static const _speech = [
    WhisperModelCatalog.baseEnglish,
    WhisperModelCatalog.tinyEnglish,
  ];
  static const _mlkitSizes = 30 * 1024 * 1024;
  static final _mlkitModels = {
    'mlkit.en': TranslateLanguage.english.bcpCode,
    'mlkit.ar': TranslateLanguage.arabic.bcpCode,
  };

  WhisperModelDescriptor? _speechById(String id) =>
      _speech.where((d) => d.id == id).firstOrNull;

  Future<bool> _speechInstalled(WhisperModelDescriptor d) async {
    try {
      return await _whisper.findCatalogModel(d) != null;
    } on FormatException {
      return false; // checksum mismatch -> treat as not installed
    }
  }

  @override
  Future<List<ModelInfo>> list() async => [
    for (final d in _speech)
      ModelInfo(
        id: d.id,
        kind: ModelKind.speech,
        name: d.id == 'base.en' ? 'Base · English' : 'Tiny · English',
        sizeBytes: d.approximateBytes,
        installed: await _speechInstalled(d),
      ),
    for (final e in _mlkitModels.entries)
      ModelInfo(
        id: e.key,
        kind: ModelKind.translation,
        name: e.key == 'mlkit.en' ? 'English' : 'Arabic',
        sizeBytes: _mlkitSizes,
        installed: await _mlkit.isModelDownloaded(e.value),
      ),
  ];

  @override
  Stream<double?> download(String id) async* {
    final speech = _speechById(id);
    if (speech != null) {
      await for (final p in _whisper.downloadCatalogModel(speech)) {
        yield p.fraction;
      }
      return;
    }
    final bcp = _mlkitModels[id];
    if (bcp == null) throw ArgumentError('Unknown model $id');
    yield null; // ML Kit gives no progress callbacks
    final ok = await _mlkit.downloadModel(bcp, isWifiRequired: false);
    if (!ok) throw StateError('Model download failed');
  }

  @override
  Future<void> remove(String id) async {
    final speech = _speechById(id);
    if (speech != null) return _whisper.delete(speech.fileName);
    final bcp = _mlkitModels[id];
    if (bcp != null) await _mlkit.deleteModel(bcp);
  }

  @override
  Future<String?> installedSpeechModelPath() async {
    for (final d in _speech) {
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
  Future<bool> translationReady() async {
    for (final bcp in _mlkitModels.values) {
      if (!await _mlkit.isModelDownloaded(bcp)) return false;
    }
    return true;
  }
}
