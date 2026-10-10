import 'package:flutter_test/flutter_test.dart';
import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/glossary/domain/entities/glossary_entry.dart';
import 'package:tarjuman/features/processing/data/glossary_text_translator.dart';
import 'package:tarjuman/features/processing/domain/ports/text_translator.dart';

class _Echo implements TextTranslator {
  final seen = <String>[];
  @override
  Future<Result<List<String>>> translateBatch(
    List<String> texts, {
    CancelToken? cancel,
  }) async {
    seen.addAll(texts);
    return Result.success(texts);
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  const entries = [
    GlossaryEntry(id: 1, term: 'state', arabic: 'حالة'),
    GlossaryEntry(id: 2, term: 'state management', arabic: 'إدارة الحالة'),
  ];

  test('swaps whole-word terms, longest first, case-insensitive', () async {
    final inner = _Echo();
    final t = GlossaryTextTranslator(inner, entries);
    await t.translateBatch([
      'State management is hard. The state matters; estate is not.',
    ]);
    expect(
      inner.seen.single,
      'إدارة الحالة is hard. The حالة matters; estate is not.',
    );
  });

  test('empty glossary passes text through untouched', () async {
    final inner = _Echo();
    await GlossaryTextTranslator(inner, const []).translateBatch(['Hello']);
    expect(inner.seen, ['Hello']);
  });
}
