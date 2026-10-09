import 'dart:io';

import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/ports/file_downloader.dart';
import 'package:tarjuman/features/library/domain/ports/media_picker.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';
import 'package:tarjuman/features/processing/domain/ports/audio_extractor.dart';

/// Direct file links only (http/https). Page links (YouTube etc.) fail the
/// content check and are rejected.
class ImportFromUrl {
  const ImportFromUrl(this._downloader, this._repository, this._probe);
  final FileDownloader _downloader;
  final VideoRepository _repository;
  final AudioExtractor _probe;

  Future<Result<Video>> call(
    String rawUrl, {
    void Function(double? fraction)? onProgress,
    CancelToken? cancel,
  }) async {
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      return const Result.failure(NetworkFailure('Invalid link'));
    }
    final downloaded = await _downloader.download(
      uri,
      onProgress: onProgress,
      cancel: cancel,
    );
    if (downloaded case Err(:final failure)) return Result.failure(failure);
    final file = (downloaded as Success<PickedFile>).value;

    final probed = await _probe.probeDuration(file.path);
    if (probed case Err()) {
      await File(file.path).delete();
      return const Result.failure(
        UnsupportedMediaFailure('Not a readable audio/video file'),
      );
    }
    return _repository.add(title: file.name, path: file.path);
  }
}
