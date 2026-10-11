import 'package:equatable/equatable.dart';

class Playlist extends Equatable {
  const Playlist({
    required this.id,
    required this.name,
    this.count = 0,
    this.lastVideoId,
  });

  final String id;
  final String name;
  final int count;
  final String? lastVideoId;

  @override
  List<Object?> get props => [id, name, count, lastVideoId];
}
