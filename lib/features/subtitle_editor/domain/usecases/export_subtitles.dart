import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_timeline.dart';
import 'package:tarjuman/features/player/domain/repositories/subtitle_repository.dart';
import 'package:tarjuman/features/player/domain/services/subtitle_serializer.dart';
import 'package:tarjuman/features/subtitle_editor/domain/ports/subtitle_exporter.dart';

class ExportSubtitles {
  const ExportSubtitles(
    this._videos,
    this._subtitles,
    this._serializer,
    this._exporter,
  );

  final VideoRepository _videos;
  final SubtitleRepository _subtitles;
  final SubtitleSerializer _serializer;
  final SubtitleExporter _exporter;

  Future<Result<void>> call(
    String videoId, {
    required bool includeOriginal,
  }) async {
    final video = await _videos.get(videoId);
    if (video case Err(:final failure)) return Result.failure(failure);
    final timeline = await _subtitles.load(videoId);
    if (timeline case Err(:final failure)) return Result.failure(failure);

    final title = (video as Success<Video>).value.title;
    final base = title.replaceAll(RegExp(r'\.[^.]{1,5}$'), '');
    final safe = base.replaceAll(RegExp(r'[^\w\-. ]+', unicode: true), '_');
    await _exporter.share(
      fileName: '$safe.ar.srt',
      content: _serializer.toSrt(
        (timeline as Success<SubtitleTimeline>).value,
        includeOriginal: includeOriginal,
      ),
    );
    return const Result.success(null);
  }
}
