import 'package:flutter/material.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/core/error/failure_message.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/usecases/export_video_file.dart';
import 'package:tarjuman/features/library/domain/usecases/extract_audio.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

enum VideoFileAction { saveToDevice, share, extractAudio }

/// Runs a save/share for a library video and reports the outcome.
Future<void> runVideoFileAction(
  BuildContext context,
  String videoId,
  VideoFileAction action,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final export = sl<ExportVideoFile>();
  if (action == VideoFileAction.extractAudio) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.extractingAudio),
        duration: const Duration(seconds: 30),
      ),
    );
  }
  final res = switch (action) {
    VideoFileAction.saveToDevice => await export.save(videoId),
    VideoFileAction.share => await export.share(videoId),
    VideoFileAction.extractAudio => await sl<ExtractAudio>()(videoId),
  };
  messenger.hideCurrentSnackBar();
  final text = switch (res) {
    Success(value: ExportOutcome.savedToDevice)
        when action == VideoFileAction.extractAudio =>
      l10n.audioSaved,
    Success(value: ExportOutcome.savedToDevice) => l10n.savedToDevice,
    Success() => null,
    Err(:final failure) => failureMessage(failure, l10n),
  };
  if (text != null) messenger.showSnackBar(SnackBar(content: Text(text)));
}
