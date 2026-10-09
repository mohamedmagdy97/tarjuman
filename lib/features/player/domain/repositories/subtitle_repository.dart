import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_timeline.dart';

abstract interface class SubtitleRepository {
  Future<Result<SubtitleTimeline>> load(String videoId);
  Future<Result<void>> replace(
    String videoId,
    SubtitleTimeline timeline,
    SubtitleOrigin origin,
  );

  /// Adds cues without changing the video's status (incremental processing).
  Future<Result<void>> append(String videoId, List<SubtitleCue> cues);

  /// Removes cues starting at or after [from] (restart a half-done chunk).
  Future<Result<void>> deleteFrom(String videoId, Duration from);
}
