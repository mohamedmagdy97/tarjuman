import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/core/settings/settings_store.dart';
import 'package:tarjuman/features/model_manager/domain/repositories/model_repository.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';

enum SetupStatus { idle, downloading, done, failed }

class OnboardingState extends Equatable {
  const OnboardingState({
    this.status = SetupStatus.idle,
    this.step = 0,
    this.totalSteps = 0,
    this.fraction,
  });

  final SetupStatus status;

  /// 1-based index of the model being downloaded.
  final int step;
  final int totalSteps;

  /// Progress of the current model (null = unknown).
  final double? fraction;

  OnboardingState copyWith({
    SetupStatus? status,
    int? step,
    int? totalSteps,
    double? fraction,
    bool clearFraction = false,
  }) => OnboardingState(
    status: status ?? this.status,
    step: step ?? this.step,
    totalSteps: totalSteps ?? this.totalSteps,
    fraction: clearFraction ? null : fraction ?? this.fraction,
  );

  @override
  List<Object?> get props => [status, step, totalSteps, fraction];
}

/// First-run: downloads the recommended models for English → Arabic so the
/// first translation just works. Everything is skippable.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._models, this._settings)
    : super(const OnboardingState());

  final ModelRepository _models;
  final SettingsStore _settings;

  Future<void> downloadStarterModels() async {
    final speech = await _models.recommendedSpeechModelId(SourceLanguage.en);
    final ids = [speech, 'mlkit.en', 'mlkit.ar'];
    final installed = {
      for (final m in await _models.list())
        if (m.installed) m.id,
    };
    final todo = ids.where((id) => !installed.contains(id)).toList();
    if (todo.isEmpty) {
      emit(const OnboardingState(status: SetupStatus.done));
      return;
    }
    emit(
      OnboardingState(status: SetupStatus.downloading, totalSteps: todo.length),
    );
    try {
      for (var i = 0; i < todo.length; i++) {
        emit(state.copyWith(step: i + 1, clearFraction: true));
        await for (final p in _models.download(todo[i])) {
          emit(state.copyWith(fraction: p, clearFraction: p == null));
        }
      }
      emit(state.copyWith(status: SetupStatus.done));
    } on Object {
      emit(state.copyWith(status: SetupStatus.failed));
    }
  }

  Future<void> finish() => _settings.writeOnboardingDone();
}
