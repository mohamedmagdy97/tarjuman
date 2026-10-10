import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_timeline.dart';
import 'package:tarjuman/features/player/domain/repositories/subtitle_repository.dart';
import 'package:tarjuman/features/player/domain/services/subtitle_serializer.dart';
import 'package:tarjuman/features/subtitle_editor/domain/ports/subtitle_exporter.dart';

class ExportTranscript {
  const ExportTranscript(this._subtitles, this._serializer, this._exporter);
  final SubtitleRepository _subtitles;
  final SubtitleSerializer _serializer;
  final SubtitleExporter _exporter;

  Future<void> call(String videoId, {required bool includeOriginal}) async {
    final res = await _subtitles.load(videoId);
    if (res case Success<SubtitleTimeline>(:final value)) {
      await _exporter.share(
        fileName: 'transcript.txt',
        content: _serializer.toText(value, includeOriginal: includeOriginal),
        mimeType: 'text/plain',
      );
    }
  }
}
