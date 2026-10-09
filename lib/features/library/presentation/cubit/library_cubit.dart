import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/usecases/delete_video.dart';
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
  });

  final List<Video> videos;
  final LibraryFilter filter;
  final bool loading;
  final bool importing;

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
  }) => LibraryState(
    videos: videos ?? this.videos,
    filter: filter ?? this.filter,
    loading: loading ?? this.loading,
    importing: importing ?? this.importing,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [videos, filter, loading, importing, failure];
}

class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit(this._watch, this._import, this._delete)
    : super(const LibraryState()) {
    _sub = _watch().listen(
      (v) => emit(state.copyWith(videos: v, loading: false)),
    );
  }

  final WatchLibrary _watch;
  final ImportVideo _import;
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
        Success() => state.copyWith(importing: false),
      },
    );
  }

  Future<void> delete(String id) => _delete(id);

  void failureShown() => emit(state.copyWith(clearFailure: true));

  @override
  Future<void> close() {
    unawaited(_sub.cancel());
    return super.close();
  }
}
