import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/features/model_manager/domain/entities/model_info.dart';
import 'package:tarjuman/features/model_manager/domain/repositories/model_repository.dart';

class ModelsState extends Equatable {
  const ModelsState({
    this.models = const [],
    this.loading = true,
    this.progress = const {},
    this.downloadFailed = false,
  });

  final List<ModelInfo> models;
  final bool loading;

  /// id -> 0..1, or null value for indeterminate.
  final Map<String, double?> progress;
  final bool downloadFailed;

  ModelsState copyWith({
    List<ModelInfo>? models,
    bool? loading,
    Map<String, double?>? progress,
    bool? downloadFailed,
  }) => ModelsState(
    models: models ?? this.models,
    loading: loading ?? this.loading,
    progress: progress ?? this.progress,
    downloadFailed: downloadFailed ?? this.downloadFailed,
  );

  @override
  List<Object?> get props => [models, loading, progress, downloadFailed];
}

class ModelsCubit extends Cubit<ModelsState> {
  ModelsCubit(this._repo) : super(const ModelsState());

  final ModelRepository _repo;

  Future<void> load() async =>
      emit(state.copyWith(models: await _repo.list(), loading: false));

  Future<void> download(String id) async {
    if (state.progress.containsKey(id)) return;
    emit(
      state.copyWith(
        progress: {...state.progress, id: 0},
        downloadFailed: false,
      ),
    );
    try {
      await for (final p in _repo.download(id)) {
        emit(state.copyWith(progress: {...state.progress, id: p}));
      }
    } on Object {
      emit(state.copyWith(downloadFailed: true));
    }
    final next = {...state.progress}..remove(id);
    emit(state.copyWith(progress: next, models: await _repo.list()));
  }

  Future<void> remove(String id) async {
    await _repo.remove(id);
    emit(state.copyWith(models: await _repo.list()));
  }

  void failureShown() => emit(state.copyWith(downloadFailed: false));
}
