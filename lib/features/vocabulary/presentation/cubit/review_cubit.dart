import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/features/vocabulary/domain/entities/vocab_word.dart';
import 'package:tarjuman/features/vocabulary/domain/repositories/vocabulary_repository.dart';
import 'package:tarjuman/features/vocabulary/domain/services/spaced_repetition.dart';

class ReviewState extends Equatable {
  const ReviewState({
    this.queue = const [],
    this.revealed = false,
    this.loading = true,
    this.reviewed = 0,
  });

  /// Cards still due, current first.
  final List<VocabWord> queue;
  final bool revealed;
  final bool loading;
  final int reviewed;

  VocabWord? get current => queue.isEmpty ? null : queue.first;

  @override
  List<Object?> get props => [queue, revealed, loading, reviewed];
}

class ReviewCubit extends Cubit<ReviewState> {
  ReviewCubit(this._vocab, this._srs, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      super(const ReviewState());

  final VocabularyRepository _vocab;
  final SpacedRepetition _srs;
  final DateTime Function() _clock;

  Future<void> load() async {
    final now = _clock();
    final due = (await _vocab.all()).where((w) => w.isDue(now)).toList()
      ..sort(
        (a, b) => (a.dueAt ?? a.createdAt).compareTo(b.dueAt ?? b.createdAt),
      );
    emit(ReviewState(queue: due, loading: false));
  }

  void reveal() => emit(
    ReviewState(
      queue: state.queue,
      revealed: true,
      loading: false,
      reviewed: state.reviewed,
    ),
  );

  Future<void> grade(ReviewGrade grade) async {
    final card = state.current;
    if (card == null) return;
    final now = _clock();
    final next = _srs.next(
      intervalDays: card.intervalDays,
      ease: card.ease,
      reps: card.reps,
      grade: grade,
      now: now,
    );
    await _vocab.saveSchedule(card.id, next);
    // "Again" cards come back later in this same session.
    final rest = state.queue.skip(1).toList();
    final queue = grade == ReviewGrade.again ? [...rest, card] : rest;
    emit(
      ReviewState(
        queue: queue,
        loading: false,
        reviewed: state.reviewed + (grade == ReviewGrade.again ? 0 : 1),
      ),
    );
  }
}
