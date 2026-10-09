import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_kit.dart';
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
    final seconds = double.tryParse(
      session.getMediaInformation()?.getDuration() ?? '',
    );
    if (seconds == null || seconds <= 0) {
      return const Result.failure(
        UnsupportedMediaFailure('Unreadable media duration'),
      );
    }
    return Result.success(Duration(milliseconds: (seconds * 1000).round()));
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
    );
    cancel?.onCancel(session.cancel);

    final code = await session.getReturnCode();
    if (cancel?.isCancelled ?? false) {
      return const Result.failure(CancelledFailure());
    }
    if (ReturnCode.isSuccess(code)) return Result.success(outPath);
    return Result.failure(
      UnsupportedMediaFailure(await session.getFailStackTrace()),
    );
  }
}
