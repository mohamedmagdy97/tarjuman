import 'package:drift/drift.dart';
import 'package:tarjuman/core/database/app_database.dart' as db;
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_timeline.dart';
import 'package:tarjuman/features/player/domain/repositories/subtitle_repository.dart';

class SubtitleRepositoryImpl implements SubtitleRepository {
  SubtitleRepositoryImpl(this._db);
  final db.AppDatabase _db;

  @override
  Future<Result<SubtitleTimeline>> load(String videoId) async {
    final rows =
        await (_db.select(_db.cues)
              ..where((t) => t.videoId.equals(videoId))
              ..orderBy([(t) => OrderingTerm.asc(t.startMs)]))
            .get();
    return Result.success(
      SubtitleTimeline(
        rows.map(
          (r) => SubtitleCue(
            start: Duration(milliseconds: r.startMs),
            end: Duration(milliseconds: r.endMs),
            text: r.body,
            original: r.original,
            status: CueStatus.values.byName(r.status),
          ),
        ),
      ),
    );
  }

  @override
  Future<Result<void>> replace(
    String videoId,
    SubtitleTimeline timeline,
    SubtitleOrigin origin,
  ) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.cues,
      )..where((t) => t.videoId.equals(videoId))).go();
      await _db.batch(
        (b) => b.insertAll(
          _db.cues,
          timeline.cues.map(
            (c) => db.CuesCompanion.insert(
              videoId: videoId,
              startMs: c.start.inMilliseconds,
              endMs: c.end.inMilliseconds,
              body: c.text,
              original: Value(c.original),
              status: Value(c.status.name),
            ),
          ),
        ),
      );
      await (_db.update(_db.videos)..where((t) => t.id.equals(videoId))).write(
        db.VideosCompanion(
          origin: Value(origin.name),
          status: const Value('ready'),
        ),
      );
    });
    return const Result.success(null);
  }

  @override
  Future<Result<void>> append(String videoId, List<SubtitleCue> cues) async {
    await _db.batch(
      (b) => b.insertAll(
        _db.cues,
        cues.map(
          (c) => db.CuesCompanion.insert(
            videoId: videoId,
            startMs: c.start.inMilliseconds,
            endMs: c.end.inMilliseconds,
            body: c.text,
            original: Value(c.original),
            status: Value(c.status.name),
          ),
        ),
      ),
    );
    return const Result.success(null);
  }

  @override
  Future<Result<void>> deleteFrom(String videoId, Duration from) async {
    await (_db.delete(_db.cues)..where(
          (t) =>
              t.videoId.equals(videoId) &
              t.startMs.isBiggerOrEqualValue(from.inMilliseconds),
        ))
        .go();
    return const Result.success(null);
  }

  @override
  Future<Result<void>> updateText(
    String videoId,
    Duration start,
    String text,
  ) async {
    await (_db.update(_db.cues)..where(
          (t) =>
              t.videoId.equals(videoId) &
              t.startMs.equals(start.inMilliseconds),
        ))
        .write(
          db.CuesCompanion(
            body: Value(text),
            status: Value(CueStatus.edited.name),
          ),
        );
    return const Result.success(null);
  }
}
