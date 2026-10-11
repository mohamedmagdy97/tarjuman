import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/core/settings/settings_store.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/usecases/export_video_file.dart';
import 'package:tarjuman/features/library/domain/usecases/import_from_url.dart';

enum DownloadStatus { queued, running, done, failed }

class DownloadRequest extends Equatable {
  const DownloadRequest({required this.url, this.title, this.referer});
  final String url;
  final String? title;
  final String? referer;

  @override
  List<Object?> get props => [url, title, referer];
}

class DownloadTask extends Equatable {
  const DownloadTask({
    required this.id,
    required this.request,
    this.status = DownloadStatus.queued,
    this.progress,
    this.failure,
    this.videoId,
    this.title,
    this.savedToDevice = false,
  });

  final int id;
  final DownloadRequest request;
  final DownloadStatus status;

  /// 0..1 while running; null when the length is unknown.
  final double? progress;
  final Failure? failure;
  final String? videoId;

  /// Real title once resolved, otherwise the requested one.
  final String? title;

  /// A public copy exists in Movies/Tarjuman.
  final bool savedToDevice;

  String get displayTitle => title ?? request.title ?? request.url;

  DownloadTask copyWith({
    DownloadStatus? status,
    double? progress,
    bool clearProgress = false,
    Failure? failure,
    bool clearFailure = false,
    String? videoId,
    String? title,
    bool? savedToDevice,
  }) => DownloadTask(
    id: id,
    request: request,
    status: status ?? this.status,
    progress: clearProgress ? null : progress ?? this.progress,
    failure: clearFailure ? null : failure ?? this.failure,
    videoId: videoId ?? this.videoId,
    title: title ?? this.title,
    savedToDevice: savedToDevice ?? this.savedToDevice,
  );

  @override
  List<Object?> get props => [
    id,
    request,
    status,
    progress,
    failure,
    videoId,
    title,
    savedToDevice,
  ];
}

class DownloadsState extends Equatable {
  const DownloadsState({this.tasks = const []});
  final List<DownloadTask> tasks;

  int get active => tasks
      .where(
        (t) =>
            t.status == DownloadStatus.queued ||
            t.status == DownloadStatus.running,
      )
      .length;

  @override
  List<Object?> get props => [tasks];
}

/// App-lifetime download queue: downloads keep going while the user browses
/// or leaves the browser page. At most [concurrency] run at once.
class DownloadsCubit extends Cubit<DownloadsState> {
  DownloadsCubit(
    this._import,
    this._export,
    this._settings, {
    this.concurrency = 2,
  }) : super(const DownloadsState());

  final ImportFromUrl _import;
  final ExportVideoFile _export;
  final SettingsStore _settings;
  final int concurrency;
  final _tokens = <int, CancelToken>{};
  var _nextId = 1;

  void add(Iterable<DownloadRequest> requests) {
    final fresh = [
      for (final r in requests)
        if (!state.tasks.any(
          (t) =>
              t.request == r &&
              (t.status == DownloadStatus.queued ||
                  t.status == DownloadStatus.running),
        ))
          DownloadTask(id: _nextId++, request: r),
    ];
    if (fresh.isEmpty) return;
    emit(DownloadsState(tasks: [...state.tasks, ...fresh]));
    _pump();
  }

  void retry(int id) {
    _update(
      id,
      (t) => t.copyWith(
        status: DownloadStatus.queued,
        clearFailure: true,
        clearProgress: true,
      ),
    );
    _pump();
  }

  void cancel(int id) {
    final token = _tokens[id];
    if (token != null) {
      token.cancel();
    } else {
      remove(id);
    }
  }

  void remove(int id) =>
      emit(DownloadsState(tasks: [...state.tasks.where((t) => t.id != id)]));

  void clearFinished() => emit(
    DownloadsState(
      tasks: [
        ...state.tasks.where(
          (t) =>
              t.status == DownloadStatus.queued ||
              t.status == DownloadStatus.running,
        ),
      ],
    ),
  );

  void _pump() {
    var running = state.tasks
        .where((t) => t.status == DownloadStatus.running)
        .length;
    for (final t in state.tasks) {
      if (running >= concurrency) break;
      if (t.status != DownloadStatus.queued) continue;
      running++;
      unawaited(_run(t));
    }
  }

  Future<void> _run(DownloadTask task) async {
    final token = _tokens[task.id] = CancelToken();
    _update(task.id, (t) => t.copyWith(status: DownloadStatus.running));
    var last = -1.0;
    final result = await _import(
      task.request.url,
      referer: task.request.referer,
      cancel: token,
      onProgress: (f) {
        if (f != null && (f - last).abs() < 0.01) return;
        last = f ?? -1;
        _update(
          task.id,
          (t) => t.copyWith(progress: f, clearProgress: f == null),
        );
      },
    );
    _tokens.remove(task.id);
    switch (result) {
      case Success<Video>(:final value):
        final saved = await _autoSave(value.id);
        _update(
          task.id,
          (t) => t.copyWith(
            status: DownloadStatus.done,
            videoId: value.id,
            title: value.title,
            progress: 1,
            savedToDevice: saved,
          ),
        );
      case Err(:final failure) when failure is CancelledFailure:
        remove(task.id);
      case Err(:final failure):
        _update(
          task.id,
          (t) => t.copyWith(
            status: DownloadStatus.failed,
            failure: failure,
            clearProgress: true,
          ),
        );
    }
    _pump();
  }

  /// Auto-save never blocks the queue on the share-sheet fallback.
  Future<bool> _autoSave(String videoId) async =>
      _settings.readAutoSaveDownloads() && await _export.saveSilently(videoId);

  void _update(int id, DownloadTask Function(DownloadTask) f) {
    if (isClosed) return;
    emit(
      DownloadsState(
        tasks: [for (final t in state.tasks) t.id == id ? f(t) : t],
      ),
    );
  }
}
