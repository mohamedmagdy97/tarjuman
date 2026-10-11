import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/playlists/domain/playlist.dart';
import 'package:tarjuman/features/playlists/domain/playlist_repository.dart';

class PlaylistsState extends Equatable {
  const PlaylistsState({this.playlists = const [], this.loading = true});
  final List<Playlist> playlists;
  final bool loading;

  @override
  List<Object?> get props => [playlists, loading];
}

class PlaylistsCubit extends Cubit<PlaylistsState> {
  PlaylistsCubit(this._repo) : super(const PlaylistsState()) {
    _sub = _repo.watchAll().listen(
      (p) => emit(PlaylistsState(playlists: p, loading: false)),
    );
  }

  final PlaylistRepository _repo;
  late final StreamSubscription<List<Playlist>> _sub;

  Future<void> create(String name) async {
    if (name.trim().isEmpty) return;
    await _repo.create(name);
  }

  Future<void> delete(String id) => _repo.delete(id);

  @override
  Future<void> close() {
    unawaited(_sub.cancel());
    return super.close();
  }
}

class PlaylistState extends Equatable {
  const PlaylistState({this.playlist, this.videos = const []});
  final Playlist? playlist;
  final List<Video> videos;

  /// Where "Play" starts: the last opened episode, else the first one.
  Video? get resumeTarget {
    if (videos.isEmpty) return null;
    final last = playlist?.lastVideoId;
    return videos.firstWhere((v) => v.id == last, orElse: () => videos.first);
  }

  @override
  List<Object?> get props => [playlist, videos];
}

class PlaylistCubit extends Cubit<PlaylistState> {
  PlaylistCubit(this._repo, this.playlistId) : super(const PlaylistState()) {
    _sub = _repo.watchVideos(playlistId).listen((v) async {
      emit(PlaylistState(playlist: await _repo.get(playlistId), videos: v));
    });
  }

  final PlaylistRepository _repo;
  final String playlistId;
  late final StreamSubscription<List<Video>> _sub;

  Future<void> addVideos(List<String> ids) => _repo.addVideos(playlistId, ids);
  Future<void> remove(String videoId) => _repo.removeVideo(playlistId, videoId);
  Future<void> rename(String name) => _repo.rename(playlistId, name);

  @override
  Future<void> close() {
    unawaited(_sub.cancel());
    return super.close();
  }
}
