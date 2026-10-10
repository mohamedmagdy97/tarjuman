import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';
import 'package:tarjuman/features/processing/domain/ports/audio_extractor.dart';

/// A file another app opened/shared with us: validate by content, then add.
class ImportSharedMedia {
  const ImportSharedMedia(this._repository, this._probe);
  final VideoRepository _repository;
  final AudioExtractor _probe;

  Future<Result<Video>> call({
    required String path,
    required String name,
  }) async {
    final probed = await _probe.probeDuration(path);
    if (probed case Err()) {
      return const Result.failure(
        UnsupportedMediaFailure('Not a readable audio/video file'),
      );
    }
    return _repository.add(
      title: name,
      path: path,
      duration: (probed as Success<Duration>).value,
    );
  }
}
