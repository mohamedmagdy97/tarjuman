import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/usecases/delete_video.dart';
import 'package:tarjuman/features/library/domain/usecases/import_from_url.dart';
import 'package:tarjuman/features/library/domain/usecases/import_video.dart';
import 'package:tarjuman/features/library/domain/usecases/watch_library.dart';

enum LibraryFilter { all, ready, processing }

class LibraryState extends Equatable {
  const LibraryState({
    this.videos = const [],
    this.filter = LibraryFilter.all,
    this.loading = true,
    this.failure,
    this.importing = false,
    this.importedId,
    this.downloading = false,
    this.downloadProgress,
  });

  final List<Video> videos;
  final LibraryFilter filter;
  final bool loading;
  final bool importing;
  final bool downloading;

  /// 0..1, or null when unknown / indeterminate.
  final double? downloadProgress;

  /// One-shot: id of a just-imported video, to open its setup screen.
  final String? importedId;

  /// One-shot: the page shows it and calls [LibraryCubit.failureShown].
  final Failure? failure;

  List<Video> get visible => switch (filter) {
    LibraryFilter.all => videos,
    LibraryFilter.ready =>
      videos.where((v) => v.status == VideoStatus.ready).toList(),
    LibraryFilter.processing =>
      videos.where((v) => v.status == VideoStatus.processing).toList(),
  };

  LibraryState copyWith({
    List<Video>? videos,
    LibraryFilter? filter,
    bool? loading,
    bool? importing,
    Failure? failure,
    bool clearFailure = false,
    String? importedId,
    bool clearImported = false,
    bool? downloading,
    double? downloadProgress,
    bool clearProgress = false,
  }) => LibraryState(
    videos: videos ?? this.videos,
    filter: filter ?? this.filter,
    loading: loading ?? this.loading,
    importing: importing ?? this.importing,
    failure: clearFailure ? null : failure ?? this.failure,
    importedId: clearImported ? null : importedId ?? this.importedId,
    downloading: downloading ?? this.downloading,
    downloadProgress: clearProgress
        ? null
        : downloadProgress ?? this.downloadProgress,
  );

  @override
  List<Object?> get props => [
    videos,
    filter,
    loading,
    importing,
    failure,
    importedId,
    downloading,
    downloadProgress,
  ];
}

class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit(this._watch, this._import, this._importUrl, this._delete)
    : super(const LibraryState()) {
    _sub = _watch().listen(
      (v) => emit(state.copyWith(videos: v, loading: false)),
    );
  }

  final WatchLibrary _watch;
  final ImportVideo _import;
  final ImportFromUrl _importUrl;
  CancelToken? _download;

  final DeleteVideo _delete;
  late final StreamSubscription<List<Video>> _sub;

  void setFilter(LibraryFilter f) => emit(state.copyWith(filter: f));

  Future<void> importVideo() async {
    emit(state.copyWith(importing: true));
    final result = await _import();
    emit(
      switch (result) {
        Err(:final failure) => state.copyWith(
          importing: false,
          failure: failure,
        ),
        Success(:final value) => state.copyWith(
          importing: false,
          importedId: value?.id,
        ),
      },
    );
  }

  Future<void> importFromUrl(String url) async {
    final token = _download = CancelToken();
    emit(state.copyWith(downloading: true, clearProgress: true));
    final result = await _importUrl(
      url,
      cancel: token,
      onProgress: (f) => emit(
        state.copyWith(downloadProgress: f, clearProgress: f == null),
      ),
    );
    _download = null;
    emit(
      switch (result) {
        Err(:final failure) when failure is CancelledFailure => state.copyWith(
          downloading: false,
          clearProgress: true,
        ),
        Err(:final failure) => state.copyWith(
          downloading: false,
          clearProgress: true,
          failure: failure,
        ),
        Success(:final value) => state.copyWith(
          downloading: false,
          clearProgress: true,
          importedId: value.id,
        ),
      },
    );
  }

  void cancelDownload() => _download?.cancel();

  Future<void> delete(String id) => _delete(id);

  void failureShown() => emit(state.copyWith(clearFailure: true));

  void importedHandled() => emit(state.copyWith(clearImported: true));

  @override
  Future<void> close() {
    unawaited(_sub.cancel());
    return super.close();
  }
}
