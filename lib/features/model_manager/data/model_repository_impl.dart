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

  static const _rev = '5359861c739e955e79d9a303bcbc70fb988958b1';
  static const _hf =
      'https://huggingface.co/ggerganov/whisper.cpp/resolve/$_rev';

  // 5-bit quantized models: about half the size and noticeably faster on
  // phones, with accuracy close to the originals (hashes pinned from the
  // same upstream revision as the plugin's catalog).
  static const _tinyEnQ = WhisperModelDescriptor(
    id: 'tiny.en-q5_1',
    fileName: 'ggml-tiny.en-q5_1.bin',
    url: '$_hf/ggml-tiny.en-q5_1.bin',
    sha256: 'c77c5766f1cef09b6b7d47f21b546cbddd4157886b3b5d6d4f709e91e66c7c2b',
    approximateBytes: 32166155,
    languageScope: WhisperModelLanguageScope.english,
    purpose: WhisperModelPurpose.transcription,
  );
  static const _baseEnQ = WhisperModelDescriptor(
    id: 'base.en-q5_1',
    fileName: 'ggml-base.en-q5_1.bin',
    url: '$_hf/ggml-base.en-q5_1.bin',
    sha256: '4baf70dd0d7c4247ba2b81fafd9c01005ac77c2f9ef064e00dcf195d0e2fdd2f',
    approximateBytes: 59721011,
    languageScope: WhisperModelLanguageScope.english,
    purpose: WhisperModelPurpose.transcription,
  );
  static const _tinyQ = WhisperModelDescriptor(
    id: 'tiny-q5_1',
    fileName: 'ggml-tiny-q5_1.bin',
    url: '$_hf/ggml-tiny-q5_1.bin',
    sha256: '818710568da3ca15689e31a743197b520007872ff9576237bda97bd1b469c3d7',
    approximateBytes: 32152673,
    languageScope: WhisperModelLanguageScope.multilingual,
    purpose: WhisperModelPurpose.transcription,
  );
  static const _baseQ = WhisperModelDescriptor(
    id: 'base-q5_1',
    fileName: 'ggml-base-q5_1.bin',
    url: '$_hf/ggml-base-q5_1.bin',
    sha256: '422f1ae452ade6f30a004d7e5c6a43195e4433bc370bf23fac9cc591f01a8898',
    approximateBytes: 59707625,
    languageScope: WhisperModelLanguageScope.multilingual,
    purpose: WhisperModelPurpose.transcription,
  );

  static const _english = [
    _baseEnQ,
    _tinyEnQ,
    WhisperModelCatalog.baseEnglish,
    WhisperModelCatalog.tinyEnglish,
  ];
  static const _multilingual = [
    _baseQ,
    _tinyQ,
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
    final scope = d.languageScope == WhisperModelLanguageScope.english
        ? 'English'
        : 'Multilingual';
    final fast = d.id.contains('q5_1') ? ' · Fast (Q5)' : '';
    return '$size · $scope$fast';
  }

  @override
  Future<String> recommendedSpeechModelId(SourceLanguage language) async {
    final big = (await _device.ramMb() ?? 0) >= _bigModelRamMb;
    if (language.isEnglish) return big ? 'base.en-q5_1' : 'tiny.en-q5_1';
    return big ? 'base-q5_1' : 'tiny-q5_1';
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
      ModelInfo(
        id: 'vad',
        kind: ModelKind.speech,
        name: 'Voice detection',
        sizeBytes: WhisperModelCatalog.sileroVad.approximateBytes,
        installed: await _vadInstalled(),
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

  Future<bool> _vadInstalled() async {
    try {
      return await _whisper.findCatalogModel(WhisperModelCatalog.sileroVad) !=
          null;
    } on FormatException {
      return false;
    }
  }

  @override
  Stream<double?> download(String id) async* {
    if (id == 'vad') {
      await for (final p in _whisper.downloadCatalogModel(
        WhisperModelCatalog.sileroVad,
      )) {
        yield p.fraction;
      }
      return;
    }
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
  Future<String?> vadModelPath() async {
    try {
      var f = await _whisper.findCatalogModel(WhisperModelCatalog.sileroVad);
      if (f == null) {
        await _whisper
            .downloadCatalogModel(WhisperModelCatalog.sileroVad)
            .drain<void>();
        f = await _whisper.findCatalogModel(WhisperModelCatalog.sileroVad);
      }
      return f?.path;
    } on Object {
      return null; // offline or checksum problem: continue without VAD
    }
  }

  @override
  Future<bool> translationReady(SourceLanguage language) async {
    for (final code in {language.code, TranslateLanguage.arabic.bcpCode}) {
      if (!await _mlkit.isModelDownloaded(code)) return false;
    }
    return true;
  }
}
