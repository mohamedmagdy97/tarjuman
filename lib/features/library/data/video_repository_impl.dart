import 'dart:io';

import 'package:drift/drift.dart';
import 'package:tarjuman/core/database/app_database.dart' as db;
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/data/media_storage.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';
import 'package:uuid/uuid.dart';

class VideoRepositoryImpl implements VideoRepository {
  VideoRepositoryImpl(this._db, this._storage);

  final db.AppDatabase _db;
  final MediaStorage _storage;
  static const _uuid = Uuid();

  @override
  Stream<List<Video>> watchAll() {
    final query = _db.select(_db.videos)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<Result<Video>> get(String id) async {
    final row = await (_db.select(
      _db.videos,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null
        ? const Result.failure(StorageFailure('Video not found'))
        : Result.success(_toEntity(row));
  }

  @override
  Future<Result<Video>> add({
    required String title,
    required String path,
  }) async {
    try {
      final id = _uuid.v4();
      final stored = await _storage.persist(path, id: id);
      final video = Video(
        id: id,
        title: title,
        path: stored,
        createdAt: DateTime.now(),
      );
      await _db.into(_db.videos).insert(_toCompanion(video));
      return Result.success(video);
    } on FileSystemException catch (e) {
      return Result.failure(StorageFailure(e.message));
    }
  }

  @override
  Future<Result<void>> update(Video video) async {
    await _db.update(_db.videos).replace(_toCompanion(video));
    return const Result.success(null);
  }

  @override
  Future<Result<void>> remove(String id) async {
    final current = await get(id);
    if (current case Success(:final value)) {
      await _storage.delete(value.path);
    }
    await (_db.delete(_db.videos)..where((t) => t.id.equals(id))).go();
    return const Result.success(null);
  }

  Video _toEntity(db.Video r) => Video(
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
  );

  db.VideosCompanion _toCompanion(Video v) => db.VideosCompanion(
    id: Value(v.id),
    title: Value(v.title),
    path: Value(v.path),
    durationMs: Value(v.duration?.inMilliseconds),
    status: Value(v.status.name),
    origin: Value(v.origin.name),
    createdAt: Value(v.createdAt),
    lastPositionMs: Value(v.lastPosition.inMilliseconds),
  );

  @override
  Future<void> savePosition(String id, Duration position) =>
      (_db.update(_db.videos)..where((t) => t.id.equals(id))).write(
        db.VideosCompanion(lastPositionMs: Value(position.inMilliseconds)),
      );
}
