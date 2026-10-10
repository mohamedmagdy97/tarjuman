import 'package:tarjuman/features/subtitle_editor/domain/ports/subtitle_exporter.dart';
import 'package:tarjuman/features/vocabulary/domain/repositories/vocabulary_repository.dart';

/// Shares the saved words as a CSV (word, translation, sentence) that Anki and
/// spreadsheets import directly.
class ExportVocabulary {
  const ExportVocabulary(this._vocab, this._exporter);
  final VocabularyRepository _vocab;
  final SubtitleExporter _exporter;

  static String csv(List<(String, String, String)> rows) {
    String q(String v) => '"${v.replaceAll('"', '""')}"';
    return [
      for (final r in rows) [r.$1, r.$2, r.$3].map(q).join(','),
    ].join('\n');
  }

  Future<void> call() async {
    final words = await _vocab.all();
    await _exporter.share(
      fileName: 'tarjuman-words.csv',
      content: csv([
        for (final w in words) (w.word, w.translation, w.sentence ?? ''),
      ]),
      mimeType: 'text/csv',
    );
  }
}
