import 'dart:async';

import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_new_audio/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/return_code.dart';
import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/processing/domain/ports/audio_extractor.dart';

/// FFmpegKit "audio" build (LGPL) -> 16 kHz mono PCM WAV, as whisper expects.
class FfmpegAudioExtractor implements AudioExtractor {
  @override
  Future<Result<Duration>> probeDuration(String mediaPath) async {
    final session = await FFprobeKit.getMediaInformation(mediaPath);
    final info = session.getMediaInformation();
    var seconds = double.tryParse(info?.getDuration() ?? '');
    if (seconds == null || seconds <= 0) {
      // Fallback: parse "Duration: hh:mm:ss.xx" from ffmpeg's banner output.
      final probe = await FFmpegKit.executeWithArguments([
        '-hide_banner',
        '-i',
        mediaPath,
      ]);
      seconds = _durationFromLog(await probe.getAllLogsAsString() ?? '');
      if (seconds == null || seconds <= 0) {
        final out = (await session.getAllLogsAsString() ?? '').trim();
        return Result.failure(
          UnsupportedMediaFailure(
            'ffprobe could not read a duration. '
            '${out.isEmpty ? 'no output' : out}',
          ),
        );
      }
    }
    return Result.success(Duration(milliseconds: (seconds * 1000).round()));
  }

  double? _durationFromLog(String log) {
    final m = RegExp(
      r'Duration:\s*(\d+):(\d+):(\d+(?:\.\d+)?)',
    ).firstMatch(log);
    if (m == null) return null;
    return int.parse(m.group(1)!) * 3600 +
        int.parse(m.group(2)!) * 60 +
        double.parse(m.group(3)!);
  }

  @override
  Future<Result<String>> extractWav({
    required String mediaPath,
    required String outPath,
    required Duration start,
    required Duration length,
    CancelToken? cancel,
  }) async {
    String secs(Duration d) => (d.inMilliseconds / 1000).toStringAsFixed(3);
    // executeWithArgumentsAsync returns immediately; wait for the complete callback.
    final done = Completer<FFmpegSession>();
    final session = await FFmpegKit.executeWithArgumentsAsync(
      [
        '-y',
        '-ss',
        secs(start),
        '-t',
        secs(length),
        '-i',
        mediaPath,
        '-vn',
        '-sn',
        '-dn',
        '-ac',
        '1',
        '-ar',
        '16000',
        '-c:a',
        'pcm_s16le',
        outPath,
      ],
      done.complete,
    );
    cancel?.onCancel(session.cancel);

    await done.future;
    final code = await session.getReturnCode();
    if (cancel?.isCancelled ?? false) {
      return const Result.failure(CancelledFailure());
    }
    if (ReturnCode.isSuccess(code)) return Result.success(outPath);
    final logs = (await session.getAllLogsAsString() ?? '').trim();
    final tail = logs.length > 600 ? logs.substring(logs.length - 600) : logs;
    return Result.failure(
      UnsupportedMediaFailure(
        'ffmpeg exit ${code?.getValue()}: ${tail.isEmpty ? 'no output' : tail}',
      ),
    );
  }
}
