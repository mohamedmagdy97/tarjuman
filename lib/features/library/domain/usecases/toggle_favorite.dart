import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';

class ToggleFavorite {
  const ToggleFavorite(this._repository);
  final VideoRepository _repository;

  Future<void> call(String id, {required bool value}) =>
      _repository.setFavorite(id, value: value);
}
