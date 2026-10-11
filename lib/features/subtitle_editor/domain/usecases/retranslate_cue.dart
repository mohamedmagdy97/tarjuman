import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/processing/domain/ports/engine_provider.dart';
import 'package:tarjuman/features/processing/domain/ports/text_translator.dart';
import 'package:tarjuman/features/subtitle_editor/domain/usecases/edit_cue_text.dart';

/// Re-translates one line with the online engine (better for tricky lines)
/// and stores the result as an edit.
class RetranslateCue {
  const RetranslateCue(this._engines, this._edit);
  final EngineProvider _engines;
  final EditCueText _edit;

  Future<Result<String>> call({
    required String videoId,
    required SubtitleCue cue,
    required SourceLanguage language,
  }) async {
    final original = cue.original;
    if (original == null || original.trim().isEmpty) {
      return const Result.failure(UnknownFailure('No source text'));
    }
    final acquired = await _engines.acquireTranslator(
      language,
      videoId: videoId,
    );
    if (acquired case Err(:final failure)) return Result.failure(failure);
    final translator = (acquired as Success<TextTranslator>).value;
    try {
      final res = await translator.translateBatch([original]);
      if (res case Err(:final failure)) return Result.failure(failure);
      final text = (res as Success<List<String>>).value.first.trim();
      await _edit(videoId, cue.start, text);
      return Result.success(text);
    } finally {
      await translator.dispose();
    }
  }
}
