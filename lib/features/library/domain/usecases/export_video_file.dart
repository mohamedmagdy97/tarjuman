import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/ports/media_exporter.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';

enum ExportOutcome { savedToDevice, shared }

/// "Save to device" with automatic fallback to the share sheet, plus plain
/// share. Works on any library video (downloaded or imported).
class ExportVideoFile {
  const ExportVideoFile(this._videos, this._exporter);
  final VideoRepository _videos;
  final MediaExporter _exporter;

  Future<Result<ExportOutcome>> save(String videoId) async {
    final video = await _find(videoId);
    if (video == null) return const Result.failure(StorageFailure('Missing'));
    final name = _fileName(video);
    if (await _exporter.saveToDevice(path: video.path, name: name)) {
      return const Result.success(ExportOutcome.savedToDevice);
    }
    await _exporter.shareFile(path: video.path, name: name);
    return const Result.success(ExportOutcome.shared);
  }

  /// Public-folder copy only; never opens the share sheet.
  Future<bool> saveSilently(String videoId) async {
    final video = await _find(videoId);
    if (video == null) return false;
    return _exporter.saveToDevice(path: video.path, name: _fileName(video));
  }

  Future<Result<ExportOutcome>> share(String videoId) async {
    final video = await _find(videoId);
    if (video == null) return const Result.failure(StorageFailure('Missing'));
    await _exporter.shareFile(path: video.path, name: _fileName(video));
    return const Result.success(ExportOutcome.shared);
  }

  Future<Video?> _find(String id) async => switch (await _videos.get(id)) {
    Success(:final value) => value,
    Err() => null,
  };

  String _fileName(Video v) {
    final ext = v.path.contains('.') ? v.path.split('.').last : 'mp4';
    final safe = v.title.replaceAll(RegExp(r'[\\/:*?"<>|\n\r]'), '_').trim();
    final base = safe.isEmpty ? 'video' : safe;
    return base.toLowerCase().endsWith('.$ext') ? base : '$base.$ext';
  }
}
