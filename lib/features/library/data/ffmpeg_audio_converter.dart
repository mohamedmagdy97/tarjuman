import 'dart:async';

import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_new_audio/return_code.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/ports/audio_converter.dart';

/// FFmpegKit audio build (LGPL, ships libmp3lame): variable-bitrate MP3,
/// roughly 190 kbps (`-q:a 2`).
class FfmpegAudioConverter implements AudioConverter {
  @override
  Future<Result<String>> toMp3({
    required String mediaPath,
    required String outPath,
  }) async {
    final done = Completer<FFmpegSession>();
    final session = await FFmpegKit.executeWithArgumentsAsync([
      '-y',
      '-i',
      mediaPath,
      '-vn',
      '-sn',
      '-dn',
      '-map_metadata',
      '-1',
      '-c:a',
      'libmp3lame',
      '-q:a',
      '2',
      outPath,
    ], done.complete);
    await done.future;
    final code = await session.getReturnCode();
    if (ReturnCode.isSuccess(code)) return Result.success(outPath);
    final logs = (await session.getAllLogsAsString() ?? '').trim();
    final tail = logs.length > 400 ? logs.substring(logs.length - 400) : logs;
    return Result.failure(
      UnsupportedMediaFailure(
        'mp3 export failed (${code?.getValue()}): $tail',
      ),
    );
  }
}
