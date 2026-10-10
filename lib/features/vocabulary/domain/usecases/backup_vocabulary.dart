import 'dart:convert';
import 'dart:io';

import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/ports/media_picker.dart';
import 'package:tarjuman/features/subtitle_editor/domain/ports/subtitle_exporter.dart';
import 'package:tarjuman/features/vocabulary/domain/repositories/vocabulary_repository.dart';

/// Backup format: {"app":"tarjuman","version":1,"words":[{word,translation,sentence}]}.
class BackupVocabulary {
  const BackupVocabulary(this._vocab, this._exporter);
  final VocabularyRepository _vocab;
  final SubtitleExporter _exporter;

  static String encode(List<Map<String, String?>> words) => jsonEncode({
    'app': 'tarjuman',
    'version': 1,
    'words': words,
  });

  Future<void> call() async {
    final words = await _vocab.all();
    await _exporter.share(
      fileName: 'tarjuman-words-backup.json',
      content: encode([
        for (final w in words)
          {
            'word': w.word,
            'translation': w.translation,
            'sentence': w.sentence,
          },
      ]),
      mimeType: 'application/json',
    );
  }
}

/// Merges a backup into the saved words (duplicates are skipped).
class RestoreVocabulary {
  const RestoreVocabulary(this._picker, this._vocab);
  final MediaPicker _picker;
  final VocabularyRepository _vocab;

  /// success(null) = cancelled; success(n) = n words added.
  Future<Result<int?>> call() async {
    final picked = await _picker.pickBackup();
    if (picked case Err(:final failure)) return Result.failure(failure);
    final file = (picked as Success<PickedFile?>).value;
    if (file == null) return const Result.success(null);
    return restore(await File(file.path).readAsString());
  }

  Future<Result<int?>> restore(String json) async {
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      if (data['app'] != 'tarjuman') throw const FormatException('not ours');
      var added = 0;
      for (final raw in (data['words'] as List<dynamic>)) {
        final w = raw as Map<String, dynamic>;
        final word = w['word'] as String;
        if (await _vocab.contains(word)) continue;
        await _vocab.add(
          word: word,
          translation: w['translation'] as String,
          sentence: w['sentence'] as String?,
        );
        added++;
      }
      return Result.success(added);
    } on Object {
      return const Result.failure(InvalidSubtitleFailure('Invalid backup'));
    }
  }
}
