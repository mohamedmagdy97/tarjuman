import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/player/domain/entities/cue_hit.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_timeline.dart';

abstract interface class SubtitleRepository {
  Future<Result<SubtitleTimeline>> load(String videoId);
  Future<Result<void>> replace(
    String videoId,
    SubtitleTimeline timeline,
    SubtitleOrigin origin,
  );

  /// Library-wide search in Arabic and source text (newest videos first).
  Future<List<CueHit>> search(String query, {int limit = 40});

  /// Edits one cue's Arabic text (identified by its start time).
  Future<Result<void>> updateText(String videoId, Duration start, String text);

  /// Tags one cue with a speaker colour (0 clears it).
  Future<Result<void>> setSpeaker(String videoId, Duration start, int speaker);

  /// Adds cues without changing the video's status (incremental processing).
  Future<Result<void>> append(String videoId, List<SubtitleCue> cues);

  /// Removes cues starting at or after [from] (restart a half-done chunk).
  Future<Result<void>> deleteFrom(String videoId, Duration from);
}
