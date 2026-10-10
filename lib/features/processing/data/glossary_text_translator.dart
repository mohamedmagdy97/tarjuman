import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/glossary/domain/entities/glossary_entry.dart';
import 'package:tarjuman/features/processing/domain/ports/text_translator.dart';

/// Decorator: swaps the user's glossary terms for their Arabic equivalents
/// before the engine translates, so domain terms come out the way the user
/// wants. Whole-word, case-insensitive; longest terms first.
class GlossaryTextTranslator implements TextTranslator {
  GlossaryTextTranslator(this._inner, List<GlossaryEntry> entries)
    : _entries = ([...entries]
        ..sort((a, b) => b.term.length.compareTo(a.term.length)));

  final TextTranslator _inner;
  final List<GlossaryEntry> _entries;

  String apply(String text) {
    var out = text;
    for (final e in _entries) {
      out = out.replaceAll(
        RegExp(
          '(?<![\\p{L}\\p{N}])${RegExp.escape(e.term)}(?![\\p{L}\\p{N}])',
          caseSensitive: false,
          unicode: true,
        ),
        e.arabic,
      );
    }
    return out;
  }

  @override
  Future<Result<List<String>>> translateBatch(
    List<String> texts, {
    CancelToken? cancel,
  }) => _inner.translateBatch(
    _entries.isEmpty ? texts : texts.map(apply).toList(),
    cancel: cancel,
  );

  @override
  Future<void> dispose() => _inner.dispose();
}
