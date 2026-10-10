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
import 'package:tarjuman/features/library/domain/usecases/toggle_favorite.dart';
import 'package:tarjuman/features/library/domain/usecases/watch_library.dart';
import 'package:tarjuman/features/player/domain/entities/cue_hit.dart';
import 'package:tarjuman/features/player/domain/usecases/search_subtitles.dart';

enum LibraryFilter { all, ready, processing, favorites }

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
    this.query = '',
    this.hits = const [],
  });

  final List<Video> videos;
  final LibraryFilter filter;
  final bool loading;
  final bool importing;
  final bool downloading;
  final String query;

  /// Subtitle lines matching [query] across the whole library.
  final List<CueHit> hits;

  /// 0..1, or null when unknown / indeterminate.
  final double? downloadProgress;

  /// One-shot: id of a just-imported video, to open its setup screen.
  final String? importedId;

  /// One-shot: the page shows it and calls [LibraryCubit.failureShown].
  final Failure? failure;

  /// Started but not finished, most recently played first.
  List<Video> get continueWatching {
    final list =
        videos.where((v) {
          final d = v.duration;
          return v.lastPosition > const Duration(seconds: 10) &&
              (d == null || v.lastPosition < d - const Duration(seconds: 10));
        }).toList()..sort(
          (a, b) => (b.lastPlayedAt ?? DateTime(0)).compareTo(
            a.lastPlayedAt ?? DateTime(0),
          ),
        );
    return list.take(6).toList();
  }

  List<Video> get visible => _byFilter
      .where(
        (v) =>
            query.trim().isEmpty ||
            v.title.toLowerCase().contains(query.trim().toLowerCase()),
      )
      .toList();

  List<Video> get _byFilter => switch (filter) {
    LibraryFilter.all => videos,
    LibraryFilter.ready =>
      videos.where((v) => v.status == VideoStatus.ready).toList(),
    LibraryFilter.processing =>
      videos.where((v) => v.status == VideoStatus.processing).toList(),
    LibraryFilter.favorites => videos.where((v) => v.isFavorite).toList(),
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
    String? query,
    List<CueHit>? hits,
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
    query: query ?? this.query,
    hits: hits ?? this.hits,
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
    query,
    hits,
  ];
}

class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit(
    this._watch,
    this._import,
    this._importUrl,
    this._delete,
    this._favorite,
    this._search,
  ) : super(const LibraryState()) {
    _sub = _watch().listen(
      (v) => emit(state.copyWith(videos: v, loading: false)),
    );
  }

  final WatchLibrary _watch;
  final ImportVideo _import;
  final ImportFromUrl _importUrl;
  CancelToken? _download;

  final DeleteVideo _delete;
  final ToggleFavorite _favorite;
  final SearchSubtitles _search;
  late final StreamSubscription<List<Video>> _sub;

  void setFilter(LibraryFilter f) => emit(state.copyWith(filter: f));

  Future<void> importVideo({bool gallery = false}) async {
    emit(state.copyWith(importing: true));
    final result = await _import(gallery: gallery);
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

  /// Filters titles instantly and looks up matching subtitle lines.
  Future<void> setQuery(String q) async {
    emit(state.copyWith(query: q, hits: const []));
    final hits = await _search(q);
    if (state.query == q) emit(state.copyWith(hits: hits));
  }

  Future<void> delete(String id) => _delete(id);

  Future<void> toggleFavorite(Video v) => _favorite(v.id, value: !v.isFavorite);

  void failureShown() => emit(state.copyWith(clearFailure: true));

  void importedHandled() => emit(state.copyWith(clearImported: true));

  @override
  Future<void> close() {
    unawaited(_sub.cancel());
    return super.close();
  }
}
