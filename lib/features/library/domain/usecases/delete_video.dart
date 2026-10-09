import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';

class DeleteVideo {
  const DeleteVideo(this._repository);
  final VideoRepository _repository;

  Future<Result<void>> call(String id) => _repository.remove(id);
}
