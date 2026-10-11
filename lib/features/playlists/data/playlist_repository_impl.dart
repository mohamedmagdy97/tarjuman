import 'package:drift/drift.dart';
import 'package:tarjuman/core/database/app_database.dart' as db;
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/playlists/domain/playlist.dart';
import 'package:tarjuman/features/playlists/domain/playlist_repository.dart';
import 'package:uuid/uuid.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  PlaylistRepositoryImpl(this._db);
  final db.AppDatabase _db;
  static const _uuid = Uuid();

  @override
  Stream<List<Playlist>> watchAll() {
    final count = _db.playlistItems.videoId.count();
    final query =
        _db.select(_db.playlists).join([
            leftOuterJoin(
              _db.playlistItems,
              _db.playlistItems.playlistId.equalsExp(_db.playlists.id),
            ),
          ])
          ..addColumns([count])
          ..groupBy([_db.playlists.id])
          ..orderBy([OrderingTerm.desc(_db.playlists.createdAt)]);
    return query.watch().map(
      (rows) => [
        for (final r in rows)
          _map(r.readTable(_db.playlists), r.read(count) ?? 0),
      ],
    );
  }

  Playlist _map(db.Playlist p, int count) => Playlist(
    id: p.id,
    name: p.name,
    count: count,
    lastVideoId: p.lastVideoId,
  );

  @override
  Future<Playlist?> get(String id) async {
    final p = await (_db.select(
      _db.playlists,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (p == null) return null;
    return _map(p, (await videoIds(id)).length);
  }

  @override
  Stream<List<Video>> watchVideos(String playlistId) {
    final query =
        _db.select(_db.playlistItems).join([
            innerJoin(
              _db.videos,
              _db.videos.id.equalsExp(_db.playlistItems.videoId),
            ),
          ])
          ..where(_db.playlistItems.playlistId.equals(playlistId))
          ..orderBy([OrderingTerm.asc(_db.playlistItems.position)]);
    return query.watch().map(
      (rows) => [for (final r in rows) _video(r.readTable(_db.videos))],
    );
  }

  Video _video(db.Video r) => Video(
    id: r.id,
    title: r.title,
    path: r.path,
    createdAt: r.createdAt,
    duration: r.durationMs == null
        ? null
        : Duration(milliseconds: r.durationMs!),
    status: VideoStatus.values.byName(r.status),
    origin: SubtitleOrigin.values.byName(r.origin),
    lastPosition: Duration(milliseconds: r.lastPositionMs),
    isFavorite: r.isFavorite,
    lastPlayedAt: r.lastPlayedMs == 0
        ? null
        : DateTime.fromMillisecondsSinceEpoch(r.lastPlayedMs),
  );

  @override
  Future<List<String>> videoIds(String playlistId) async {
    final rows =
        await (_db.select(_db.playlistItems)
              ..where((t) => t.playlistId.equals(playlistId))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    return [for (final r in rows) r.videoId];
  }

  @override
  Future<Playlist> create(String name) async {
    final id = _uuid.v4();
    await _db
        .into(_db.playlists)
        .insert(
          db.PlaylistsCompanion.insert(
            id: id,
            name: name.trim(),
            createdAt: DateTime.now(),
          ),
        );
    return Playlist(id: id, name: name.trim());
  }

  @override
  Future<Playlist> getOrCreate(String name) async {
    final existing = await (_db.select(
      _db.playlists,
    )..where((t) => t.name.equals(name.trim()))).get();
    if (existing.isNotEmpty) {
      final p = existing.first;
      return _map(p, (await videoIds(p.id)).length);
    }
    return create(name);
  }

  @override
  Future<void> addVideos(String playlistId, List<String> videoIds) async {
    final current = await this.videoIds(playlistId);
    var position = current.length;
    await _db.batch((b) {
      for (final id in videoIds) {
        if (current.contains(id)) continue;
        b.insert(
          _db.playlistItems,
          db.PlaylistItemsCompanion.insert(
            playlistId: playlistId,
            videoId: id,
            position: position++,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  @override
  Future<void> removeVideo(String playlistId, String videoId) async {
    await (_db.delete(_db.playlistItems)..where(
          (t) => t.playlistId.equals(playlistId) & t.videoId.equals(videoId),
        ))
        .go();
    // Close the gap so positions stay 0..n-1.
    final ids = await videoIds(playlistId);
    await _db.batch((b) {
      for (var i = 0; i < ids.length; i++) {
        b.update(
          _db.playlistItems,
          db.PlaylistItemsCompanion(position: Value(i)),
          where: (t) =>
              t.playlistId.equals(playlistId) & t.videoId.equals(ids[i]),
        );
      }
    });
  }

  @override
  Future<void> rename(String playlistId, String name) =>
      (_db.update(_db.playlists)..where((t) => t.id.equals(playlistId))).write(
        db.PlaylistsCompanion(name: Value(name.trim())),
      );

  @override
  Future<void> delete(String playlistId) =>
      (_db.delete(_db.playlists)..where((t) => t.id.equals(playlistId))).go();

  @override
  Future<void> setLast(String playlistId, String videoId) =>
      (_db.update(_db.playlists)..where((t) => t.id.equals(playlistId))).write(
        db.PlaylistsCompanion(lastVideoId: Value(videoId)),
      );
}
