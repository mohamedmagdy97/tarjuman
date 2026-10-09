import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';

abstract interface class VideoRepository {
  Stream<List<Video>> watchAll();
  Future<Result<Video>> get(String id);
  Future<Result<Video>> add({
    required String title,
    required String path,
    Duration? duration,
  });
  Future<Result<void>> update(Video video);
  Future<Result<void>> remove(String id);
  Future<void> savePosition(String id, Duration position);
}
