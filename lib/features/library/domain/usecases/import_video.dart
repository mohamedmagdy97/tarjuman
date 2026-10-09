import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/ports/media_picker.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';

class ImportVideo {
  const ImportVideo(this._picker, this._repository);
  final MediaPicker _picker;
  final VideoRepository _repository;

  /// success(null) = user cancelled.
  Future<Result<Video?>> call() async {
    final picked = await _picker.pickVideo();
    return switch (picked) {
      Err(:final failure) => Result.failure(failure),
      Success(:final value) when value == null => const Result.success(null),
      Success(:final value) => (await _repository.add(
        title: value!.name,
        path: value.path,
      )).map<Video?>((v) => v),
    };
  }
}
