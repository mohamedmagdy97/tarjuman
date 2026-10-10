import 'package:equatable/equatable.dart';

class VideoUsage extends Equatable {
  const VideoUsage({
    required this.id,
    required this.title,
    required this.bytes,
  });
  final String id;
  final String title;
  final int bytes;

  @override
  List<Object?> get props => [id, title, bytes];
}

class StorageUsage extends Equatable {
  const StorageUsage({
    this.videos = const [],
    this.modelsBytes = 0,
    this.tempBytes = 0,
  });

  /// Videos stored inside the app, biggest first.
  final List<VideoUsage> videos;
  final int modelsBytes;

  /// Leftover work files (audio chunks, interrupted imports/downloads).
  final int tempBytes;

  int get videosBytes => videos.fold(0, (a, v) => a + v.bytes);
  int get totalBytes => videosBytes + modelsBytes + tempBytes;

  @override
  List<Object?> get props => [videos, modelsBytes, tempBytes];
}
