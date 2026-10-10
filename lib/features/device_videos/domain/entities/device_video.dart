import 'package:equatable/equatable.dart';

class DeviceVideo extends Equatable {
  const DeviceVideo({
    required this.id,
    required this.title,
    required this.duration,
  });

  final String id;
  final String title;
  final Duration duration;

  @override
  List<Object?> get props => [id, title, duration];
}

enum DeviceAccess { granted, limited, denied }
