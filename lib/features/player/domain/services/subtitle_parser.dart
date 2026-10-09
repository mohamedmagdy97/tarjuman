import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';

/// Parses SRT and WebVTT text into cues. Tolerant of BOM, CRLF, cue ids,
/// styling tags and NOTE/STYLE blocks.
class SubtitleParser {
  const SubtitleParser();

  static final _timing = RegExp(
    r'((?:\d+:)?\d{1,2}:\d{2}[,.]\d{1,3})\s*-->\s*((?:\d+:)?\d{1,2}:\d{2}[,.]\d{1,3})',
  );
  static final _tags = RegExp(r'<[^>]+>|\{\\[^}]*\}');

  Result<List<SubtitleCue>> parse(String content) {
    final normalized = content
        .replaceFirst('﻿', '')
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');
    final cues = <SubtitleCue>[];

    for (final block in normalized.split(RegExp(r'\n{2,}'))) {
      final lines = block.split('\n');
      final i = lines.indexWhere(_timing.hasMatch);
      if (i < 0) continue;
      final m = _timing.firstMatch(lines[i])!;
      final start = _toDuration(m.group(1)!);
      final end = _toDuration(m.group(2)!);
      final text = lines
          .skip(i + 1)
          .map((l) => l.replaceAll(_tags, '').trim())
          .where((l) => l.isNotEmpty)
          .join('\n');
      if (text.isEmpty || end <= start) continue;
      cues.add(SubtitleCue(start: start, end: end, text: text));
    }

    if (cues.isEmpty) {
      return const Result.failure(
        UnsupportedMediaFailure('No subtitle cues found'),
      );
    }
    return Result.success(cues);
  }

  Duration _toDuration(String raw) {
    final parts = raw.replaceAll(',', '.').split(':');
    final secParts = parts.last.split('.');
    final millis = int.parse(secParts[1].padRight(3, '0').substring(0, 3));
    final hours = parts.length == 3 ? int.parse(parts.first) : 0;
    final minutes = int.parse(parts[parts.length - 2]);
    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: int.parse(secParts[0]),
      milliseconds: millis,
    );
  }
}
