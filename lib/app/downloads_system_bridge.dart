import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tarjuman/core/platform/background/background_processing.dart';
import 'package:tarjuman/core/platform/notifications/app_notifier.dart';
import 'package:tarjuman/features/downloads/presentation/cubit/downloads_cubit.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

/// Connects the download queue to the OS: keeps the app alive in the
/// background while downloads run (foreground service + progress text) and
/// posts a notification when a download finishes or fails.
class DownloadsSystemBridge {
  DownloadsSystemBridge(this._cubit, this._background, this._notifier);

  final DownloadsCubit _cubit;
  final BackgroundProcessing _background;
  final AppNotifier _notifier;
  StreamSubscription<DownloadsState>? _sub;
  StreamSubscription<String>? _taps;
  final _notified = <int>{};
  var _serviceOn = false;

  static const _owner = 'downloads';

  Future<void> start(
    GoRouter router,
    GlobalKey<ScaffoldMessengerState> messenger,
  ) async {
    AppLocalizations? l10n() {
      final ctx = messenger.currentContext;
      return ctx == null || !ctx.mounted ? null : AppLocalizations.of(ctx);
    }

    _taps ??= _notifier.taps.listen((route) => unawaited(router.push(route)));
    final launch = await _notifier.launchPayload();
    if (launch != null) unawaited(router.push(launch));

    _sub ??= _cubit.stream.listen((s) {
      final t = l10n();
      if (t == null) return;
      _syncService(s, t);
      _notifyFinished(s, t);
    });
  }

  void _syncService(DownloadsState s, AppLocalizations t) {
    if (s.active == 0) {
      if (_serviceOn) {
        _serviceOn = false;
        unawaited(_background.stop(owner: _owner));
      }
      return;
    }
    final text = _progressText(s, t);
    if (!_serviceOn) {
      _serviceOn = true;
      unawaited(
        _background.start(
          owner: _owner,
          title: t.downloadingNotificationTitle,
          text: text,
        ),
      );
    } else {
      unawaited(_background.update(text));
    }
  }

  String _progressText(DownloadsState s, AppLocalizations t) {
    final running = s.tasks.where((x) => x.status == DownloadStatus.running);
    final first = running.isEmpty ? null : running.first;
    final pct = first?.progress == null
        ? ''
        : ' · ${(first!.progress! * 100).round()}%';
    return '${t.downloadingCount(s.active)}$pct';
  }

  void _notifyFinished(DownloadsState s, AppLocalizations t) {
    for (final task in s.tasks) {
      final finished =
          task.status == DownloadStatus.done ||
          task.status == DownloadStatus.failed;
      if (!finished || !_notified.add(task.id)) continue;
      final done = task.status == DownloadStatus.done;
      unawaited(
        _notifier.show(
          id: task.id,
          title: done ? t.downloadFinishedTitle : t.downloadFailedTitle,
          body: task.displayTitle,
          payload: done && task.videoId != null
              ? '/setup/${task.videoId}'
              : '/downloads',
        ),
      );
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _taps?.cancel();
  }
}
