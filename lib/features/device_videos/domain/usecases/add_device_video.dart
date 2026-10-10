import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/device_videos/domain/entities/device_video.dart';
import 'package:tarjuman/features/device_videos/domain/ports/device_video_source.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';

/// Adds a gallery video to the library by reference (no copy).
class AddDeviceVideo {
  const AddDeviceVideo(this._source, this._videos);
  final DeviceVideoSource _source;
  final VideoRepository _videos;

  Future<Result<Video>> call(DeviceVideo item) async {
    final path = await _source.resolvePath(item.id);
    if (path == null) {
      return const Result.failure(StorageFailure('Gallery file not reachable'));
    }
    return _videos.addExternal(
      title: item.title,
      path: path,
      duration: item.duration,
    );
  }
}
