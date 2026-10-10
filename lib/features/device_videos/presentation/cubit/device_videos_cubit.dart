import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/device_videos/domain/entities/device_video.dart';
import 'package:tarjuman/features/device_videos/domain/ports/device_video_source.dart';
import 'package:tarjuman/features/device_videos/domain/usecases/add_device_video.dart';

class DeviceVideosState extends Equatable {
  const DeviceVideosState({
    this.access,
    this.videos = const [],
    this.loading = true,
    this.endReached = false,
    this.openedId,
    this.error = false,
  });

  /// null until the permission prompt has been answered.
  final DeviceAccess? access;
  final List<DeviceVideo> videos;
  final bool loading;
  final bool endReached;

  /// One-shot: id of the library entry just created, to open its setup.
  final String? openedId;
  final bool error;

  DeviceVideosState copyWith({
    DeviceAccess? access,
    List<DeviceVideo>? videos,
    bool? loading,
    bool? endReached,
    String? openedId,
    bool clearOpened = false,
    bool? error,
  }) => DeviceVideosState(
    access: access ?? this.access,
    videos: videos ?? this.videos,
    loading: loading ?? this.loading,
    endReached: endReached ?? this.endReached,
    openedId: clearOpened ? null : openedId ?? this.openedId,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [
    access,
    videos,
    loading,
    endReached,
    openedId,
    error,
  ];
}

class DeviceVideosCubit extends Cubit<DeviceVideosState> {
  DeviceVideosCubit(this._source, this._add) : super(const DeviceVideosState());

  final DeviceVideoSource _source;
  final AddDeviceVideo _add;
  var _page = 0;
  final _thumbs = <String, Future<Uint8List?>>{};

  Future<void> start() async {
    final access = await _source.requestAccess();
    emit(
      state.copyWith(access: access, loading: access != DeviceAccess.denied),
    );
    if (access != DeviceAccess.denied) await loadMore();
  }

  Future<void> loadMore() async {
    if (state.endReached) return;
    final items = await _source.page(_page);
    _page++;
    emit(
      state.copyWith(
        videos: [...state.videos, ...items],
        loading: false,
        endReached: items.isEmpty,
      ),
    );
  }

  Future<Uint8List?> thumbnail(String id) =>
      _thumbs.putIfAbsent(id, () => _source.thumbnail(id));

  Future<void> pick(DeviceVideo v) async {
    final res = await _add(v);
    emit(
      switch (res) {
        Success(:final value) => state.copyWith(openedId: value.id),
        Err() => state.copyWith(error: true),
      },
    );
  }

  void openedHandled() => emit(state.copyWith(clearOpened: true, error: false));

  Future<void> openSettings() => _source.openSettings();
}
