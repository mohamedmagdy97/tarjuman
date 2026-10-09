import 'package:equatable/equatable.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_timeline.dart';
import 'package:tarjuman/features/player/domain/repositories/subtitle_repository.dart';

class PlayerData extends Equatable {
  const PlayerData(this.video, this.timeline);
  final Video video;
  final SubtitleTimeline timeline;

  @override
  List<Object?> get props => [video, timeline.cues.length];
}

class LoadPlayerData {
  const LoadPlayerData(this._videos, this._subtitles);
  final VideoRepository _videos;
  final SubtitleRepository _subtitles;

  Future<Result<PlayerData>> call(String videoId) async {
    final video = await _videos.get(videoId);
    if (video case Err(:final failure)) return Result.failure(failure);
    final timeline = await _subtitles.load(videoId);
    return switch (timeline) {
      Err(:final failure) => Result.failure(failure),
      Success(:final value) => Result.success(
        PlayerData((video as Success<Video>).value, value),
      ),
    };
  }
}
