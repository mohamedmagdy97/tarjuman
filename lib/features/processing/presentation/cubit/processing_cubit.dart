import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/platform/background/background_processing.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
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
    this.partialReady = false,
  });

  final ProcessingStatus status;
  final ProcessingStage stage;
  final double fraction;
  final Duration? remaining;
  final Failure? failure;

  /// Some cues are saved, so the video can be played while processing.
  final bool partialReady;

  ProcessingState copyWith({
    ProcessingStatus? status,
    ProcessingStage? stage,
    double? fraction,
    Duration? remaining,
    Failure? failure,
    bool? partialReady,
  }) => ProcessingState(
    status: status ?? this.status,
    stage: stage ?? this.stage,
    fraction: fraction ?? this.fraction,
    remaining: remaining ?? this.remaining,
    failure: failure ?? this.failure,
    partialReady: partialReady ?? this.partialReady,
  );

  @override
  List<Object?> get props => [
    status,
    stage,
    fraction,
    remaining,
    failure?.runtimeType,
    partialReady,
  ];
}

class ProcessingCubit extends Cubit<ProcessingState> {
  ProcessingCubit({
    required this.videoId,
    required this.kind,
    required RunProcessingPipeline pipeline,
    required BackgroundProcessing background,
    required this.notificationTitle,
    required this.notificationText,
    this.language = SourceLanguage.en,
  }) : _background = background,
       _pipeline = pipeline,
       super(const ProcessingState());

  final String videoId;
  final EngineKind kind;
  final SourceLanguage language;
  final RunProcessingPipeline _pipeline;
  final BackgroundProcessing _background;
  final String notificationTitle;
  final String Function(int percent) notificationText;
  var _lastPercent = -1;
  CancelToken _cancel = CancelToken();
  StreamSubscription<ProcessingEvent>? _sub;

  void start() {
    _cancel = CancelToken();
    unawaited(WakelockPlus.enable()); // keep the screen on during long jobs
    _lastPercent = -1;
    unawaited(
      _background.start(
        owner: 'processing',
        title: notificationTitle,
        text: notificationText(0),
      ),
    );
    emit(const ProcessingState());
    _sub =
        _pipeline(
          videoId: videoId,
          kind: kind,
          language: language,
          cancel: _cancel,
        ).listen(
          (e) => emit(
            switch (e) {
              ProcessingProgress() => state.copyWith(
                stage: e.stage,
                fraction: e.fraction,
                remaining: e.remaining,
              ),
              ProcessingPartial() => state.copyWith(partialReady: true),
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
    final next = change.nextState;
    if (next.status == ProcessingStatus.running) {
      final pct = (next.fraction * 100).floor();
      if (pct != _lastPercent) {
        _lastPercent = pct;
        unawaited(_background.update(notificationText(pct)));
      }
    }
    if (change.nextState.status != ProcessingStatus.running) {
      unawaited(WakelockPlus.disable());
      unawaited(_background.stop(owner: 'processing'));
    }
  }

  @override
  Future<void> close() async {
    _cancel.cancel();
    unawaited(WakelockPlus.disable());
    unawaited(_background.stop(owner: 'processing'));
    await _sub?.cancel();
    return super.close();
  }
}
