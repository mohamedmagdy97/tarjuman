import 'dart:io';

import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/link_normalizer.dart';
import 'package:tarjuman/features/library/domain/ports/file_downloader.dart';
import 'package:tarjuman/features/library/domain/ports/link_source.dart';
import 'package:tarjuman/features/library/domain/ports/media_picker.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';
import 'package:tarjuman/features/processing/domain/ports/audio_extractor.dart';

/// Any http/https link: a direct file, a YouTube/social post or a web page
/// containing a video. The link is resolved to a [LinkSource], downloaded,
/// then validated by content.
class ImportFromUrl {
  const ImportFromUrl(
    this._resolver,
    this._downloader,
    this._repository,
    this._probe,
  );
  final LinkResolver _resolver;
  final FileDownloader _downloader;
  final VideoRepository _repository;
  final AudioExtractor _probe;

  Future<Result<Video>> call(
    String rawUrl, {
    String? referer,
    void Function(double? fraction)? onProgress,
    CancelToken? cancel,
  }) async {
    final uri = normalizeUrl(rawUrl);
    if (uri == null) return const Result.failure(InvalidLinkFailure());
    final resolved = await _resolver.resolve(uri, referer: referer);
    if (resolved case Err(:final failure)) return Result.failure(failure);
    final source = (resolved as Success<LinkSource>).value;
    final downloaded = await _downloader.download(
      source,
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
    return _repository.add(
      title: source.title,
      path: file.path,
      duration: (probed as Success<Duration>).value,
    );
  }
}
