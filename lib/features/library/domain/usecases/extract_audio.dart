import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/ports/audio_converter.dart';
import 'package:tarjuman/features/library/domain/ports/media_exporter.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';
import 'package:tarjuman/features/library/domain/usecases/export_video_file.dart';

/// Converts a library video's audio to MP3 and puts it in Music/Tarjuman
/// (or opens the share sheet where silent saving isn't possible).
class ExtractAudio {
  const ExtractAudio(this._videos, this._converter, this._exporter);
  final VideoRepository _videos;
  final AudioConverter _converter;
  final MediaExporter _exporter;

  Future<Result<ExportOutcome>> call(String videoId) async {
    final got = await _videos.get(videoId);
    if (got case Err(:final failure)) return Result.failure(failure);
    final video = (got as Success<Video>).value;

    final dir = await getTemporaryDirectory();
    final name = '${_safe(video.title)}.mp3';
    final out = p.join(
      dir.path,
      'mp3_${DateTime.now().millisecondsSinceEpoch}.mp3',
    );
    final converted = await _converter.toMp3(
      mediaPath: video.path,
      outPath: out,
    );
    if (converted case Err(:final failure)) {
      await _cleanup(out);
      return Result.failure(failure);
    }
    try {
      if (await _exporter.saveToDevice(path: out, name: name)) {
        return const Result.success(ExportOutcome.savedToDevice);
      }
      await _exporter.shareFile(path: out, name: name);
      return const Result.success(ExportOutcome.shared);
    } on Object catch (e) {
      return Result.failure(StorageFailure(e.toString()));
    } finally {
      await _cleanup(out);
    }
  }

  Future<void> _cleanup(String path) async {
    final f = File(path);
    if (f.existsSync()) await f.delete();
  }

  String _safe(String title) {
    final s = title.replaceAll(RegExp(r'[\\/:*?"<>|\n\r]'), '_').trim();
    return s.isEmpty ? 'audio' : s;
  }
}
