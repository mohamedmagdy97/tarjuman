import 'package:equatable/equatable.dart';
import 'package:tarjuman/core/error/failure.dart';

/// Which implementation set does the work. Both share the same ports.
enum EngineKind { offline, online }

enum ProcessingMode { prepare, live }

enum ProcessingStage { preparing, extractingAudio, transcribing, translating }

sealed class ProcessingEvent extends Equatable {
  const ProcessingEvent();
  @override
  List<Object?> get props => [];
}

final class ProcessingProgress extends ProcessingEvent {
  const ProcessingProgress({
    required this.stage,
    required this.fraction,
    this.remaining,
  });

  final ProcessingStage stage;

  /// 0..1 across the whole video.
  final double fraction;
  final Duration? remaining;

  @override
  List<Object?> get props => [stage, fraction, remaining];
}

final class ProcessingDone extends ProcessingEvent {
  const ProcessingDone();
}

final class ProcessingFailed extends ProcessingEvent {
  const ProcessingFailed(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure.runtimeType, failure.message];
}

final class ProcessingCancelled extends ProcessingEvent {
  const ProcessingCancelled();
}
