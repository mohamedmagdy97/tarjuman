import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/playlists/domain/playlist.dart';

abstract interface class PlaylistRepository {
  Stream<List<Playlist>> watchAll();
  Future<Playlist?> get(String id);

  /// Videos of a playlist in play order.
  Stream<List<Video>> watchVideos(String playlistId);
  Future<List<String>> videoIds(String playlistId);

  Future<Playlist> create(String name);

  /// The playlist called [name], creating it when missing.
  Future<Playlist> getOrCreate(String name);

  /// Appends videos, skipping ones already in the playlist.
  Future<void> addVideos(String playlistId, List<String> videoIds);
  Future<void> removeVideo(String playlistId, String videoId);
  Future<void> rename(String playlistId, String name);
  Future<void> delete(String playlistId);
  Future<void> setLast(String playlistId, String videoId);
}
