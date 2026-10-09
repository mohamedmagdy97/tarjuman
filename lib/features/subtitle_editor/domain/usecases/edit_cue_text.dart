import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/player/domain/repositories/subtitle_repository.dart';

class EditCueText {
  const EditCueText(this._subtitles);
  final SubtitleRepository _subtitles;

  Future<Result<void>> call(String videoId, Duration start, String text) =>
      _subtitles.updateText(videoId, start, text.trim());
}
