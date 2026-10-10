import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';
import 'package:tarjuman/features/library/domain/usecases/delete_video.dart';
import 'package:tarjuman/features/storage/domain/entities/storage_usage.dart';
import 'package:tarjuman/features/storage/domain/ports/storage_inspector.dart';

class StorageState extends Equatable {
  const StorageState({
    this.usage = const StorageUsage(),
    this.loading = true,
    this.freed,
  });
  final StorageUsage usage;
  final bool loading;

  /// One-shot: bytes freed by the last "clear temp".
  final int? freed;

  @override
  List<Object?> get props => [usage, loading, freed];
}

class StorageCubit extends Cubit<StorageState> {
  StorageCubit(this._inspector, this._videos, this._delete)
    : super(const StorageState());

  final StorageInspector _inspector;
  final VideoRepository _videos;
  final DeleteVideo _delete;

  Future<void> load() async {
    final all = await _videos.watchAll().first;
    emit(StorageState(usage: await _inspector.measure(all), loading: false));
  }

  Future<void> clearTemp() async {
    final freed = await _inspector.clearTemp();
    await load();
    emit(StorageState(usage: state.usage, loading: false, freed: freed));
  }

  Future<void> deleteVideo(String id) async {
    await _delete(id);
    await load();
  }
}
