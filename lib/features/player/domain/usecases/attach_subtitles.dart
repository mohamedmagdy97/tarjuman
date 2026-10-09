import 'dart:io';

import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/ports/media_picker.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_timeline.dart';
import 'package:tarjuman/features/player/domain/repositories/subtitle_repository.dart';
import 'package:tarjuman/features/player/domain/services/subtitle_parser.dart';

/// Picks an SRT/VTT file, parses it and stores it for a video.
class AttachSubtitles {
  const AttachSubtitles(this._picker, this._parser, this._subtitles);

  final MediaPicker _picker;
  final SubtitleParser _parser;
  final SubtitleRepository _subtitles;

  /// success(null) = user cancelled.
  Future<Result<SubtitleTimeline?>> call(String videoId) async {
    final picked = await _picker.pickSubtitle();
    if (picked case Err(:final failure)) return Result.failure(failure);
    final file = (picked as Success<PickedFile?>).value;
    if (file == null) return const Result.success(null);

    final String text;
    try {
      text = await File(file.path).readAsString();
    } on FileSystemException catch (e) {
      return Result.failure(StorageFailure(e.message));
    } on FormatException {
      return const Result.failure(
        InvalidSubtitleFailure('Subtitle file must be UTF-8'),
      );
    }

    final parsed = _parser.parse(text);
    if (parsed case Err(:final failure)) return Result.failure(failure);
    final timeline = SubtitleTimeline(
      (parsed as Success<List<SubtitleCue>>).value,
    );

    final saved = await _subtitles.replace(
      videoId,
      timeline,
      SubtitleOrigin.imported,
    );
    if (saved case Err(:final failure)) return Result.failure(failure);
    return Result.success(timeline);
  }
}
