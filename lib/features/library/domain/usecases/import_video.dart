import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/ports/media_picker.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';
import 'package:tarjuman/features/processing/domain/ports/audio_extractor.dart';

/// Accepts any file the picker returns, then validates by content (not by
/// extension): if FFmpeg can read a duration from it, it is importable.
class ImportVideo {
  const ImportVideo(this._picker, this._repository, this._probe);
  final MediaPicker _picker;
  final VideoRepository _repository;
  final AudioExtractor _probe;

  /// success(null) = user cancelled.
  Future<Result<Video?>> call() async {
    final picked = await _picker.pickVideo();
    if (picked case Err(:final failure)) return Result.failure(failure);
    final file = (picked as Success<PickedFile?>).value;
    if (file == null) return const Result.success(null);

    final probed = await _probe.probeDuration(file.path);
    if (probed case Err()) {
      return const Result.failure(
        UnsupportedMediaFailure('Not a readable audio/video file'),
      );
    }
    final added = await _repository.add(title: file.name, path: file.path);
    return added.map<Video?>((v) => v);
  }
}
