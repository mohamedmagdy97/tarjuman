import 'package:equatable/equatable.dart';

enum VideoStatus { imported, processing, ready, failed }

/// Where the current subtitles came from. Drives the offline/online badge.
enum SubtitleOrigin { none, imported, offline, online }

class Video extends Equatable {
  const Video({
    required this.id,
    required this.title,
    required this.path,
    required this.createdAt,
    this.duration,
    this.status = VideoStatus.imported,
    this.origin = SubtitleOrigin.none,
    this.lastPosition = Duration.zero,
    this.isFavorite = false,
    this.isExternal = false,
  });

  final String id;
  final String title;
  final String path;
  final DateTime createdAt;
  final Duration? duration;
  final VideoStatus status;
  final SubtitleOrigin origin;
  final Duration lastPosition;
  final bool isFavorite;

  /// The file lives outside the app (gallery); never delete it from disk.
  final bool isExternal;

  bool get hasSubtitles => origin != SubtitleOrigin.none;

  Video copyWith({
    Duration? duration,
    VideoStatus? status,
    SubtitleOrigin? origin,
    Duration? lastPosition,
    bool? isFavorite,
  }) => Video(
    id: id,
    title: title,
    path: path,
    createdAt: createdAt,
    duration: duration ?? this.duration,
    status: status ?? this.status,
    origin: origin ?? this.origin,
    lastPosition: lastPosition ?? this.lastPosition,
    isFavorite: isFavorite ?? this.isFavorite,
    isExternal: isExternal,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    path,
    createdAt,
    duration,
    status,
    origin,
    lastPosition,
    isFavorite,
    isExternal,
  ];
}
