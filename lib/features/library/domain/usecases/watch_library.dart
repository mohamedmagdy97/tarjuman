import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';

class WatchLibrary {
  const WatchLibrary(this._repository);
  final VideoRepository _repository;

  Stream<List<Video>> call() => _repository.watchAll();
}
