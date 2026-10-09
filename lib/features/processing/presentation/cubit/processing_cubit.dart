import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/domain/usecases/run_processing_pipeline.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

enum ProcessingStatus { running, done, failed, cancelled }

class ProcessingState extends Equatable {
  const ProcessingState({
    this.status = ProcessingStatus.running,
    this.stage = ProcessingStage.preparing,
    this.fraction = 0,
    this.remaining,
    this.failure,
  });

  final ProcessingStatus status;
  final ProcessingStage stage;
  final double fraction;
  final Duration? remaining;
  final Failure? failure;

  ProcessingState copyWith({
    ProcessingStatus? status,
    ProcessingStage? stage,
    double? fraction,
    Duration? remaining,
    Failure? failure,
  }) => ProcessingState(
    status: status ?? this.status,
    stage: stage ?? this.stage,
    fraction: fraction ?? this.fraction,
    remaining: remaining ?? this.remaining,
    failure: failure ?? this.failure,
  );

  @override
  List<Object?> get props => [
    status,
    stage,
    fraction,
    remaining,
    failure?.runtimeType,
  ];
}

class ProcessingCubit extends Cubit<ProcessingState> {
  ProcessingCubit({
    required this.videoId,
    required this.kind,
    required RunProcessingPipeline pipeline,
  }) : _pipeline = pipeline,
       super(const ProcessingState());

  final String videoId;
  final EngineKind kind;
  final RunProcessingPipeline _pipeline;
  CancelToken _cancel = CancelToken();
  StreamSubscription<ProcessingEvent>? _sub;

  void start() {
    _cancel = CancelToken();
    unawaited(WakelockPlus.enable()); // keep the screen on during long jobs
    emit(const ProcessingState());
    _sub = _pipeline(videoId: videoId, kind: kind, cancel: _cancel).listen(
      (e) => emit(
        switch (e) {
          ProcessingProgress() => state.copyWith(
            stage: e.stage,
            fraction: e.fraction,
            remaining: e.remaining,
          ),
          ProcessingDone() => state.copyWith(
            status: ProcessingStatus.done,
            fraction: 1,
          ),
          ProcessingFailed() => state.copyWith(
            status: ProcessingStatus.failed,
            failure: e.failure,
          ),
          ProcessingCancelled() => state.copyWith(
            status: ProcessingStatus.cancelled,
          ),
        },
      ),
    );
  }

  void cancel() => _cancel.cancel();

  @override
  void onChange(Change<ProcessingState> change) {
    super.onChange(change);
    if (change.nextState.status != ProcessingStatus.running) {
      unawaited(WakelockPlus.disable());
    }
  }

  @override
  Future<void> close() async {
    _cancel.cancel();
    unawaited(WakelockPlus.disable());
    await _sub?.cancel();
    return super.close();
  }
}
