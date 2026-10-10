import 'package:equatable/equatable.dart';

class VocabWord extends Equatable {
  const VocabWord({
    required this.id,
    required this.word,
    required this.translation,
    required this.createdAt,
    this.sentence,
    this.dueAt,
    this.intervalDays = 0,
    this.ease = 2.5,
    this.reps = 0,
  });

  final int id;
  final String word;
  final String translation;
  final String? sentence;
  final DateTime createdAt;

  /// Next review; null = due now (never reviewed).
  final DateTime? dueAt;
  final int intervalDays;
  final double ease;
  final int reps;

  bool isDue(DateTime now) => dueAt == null || !dueAt!.isAfter(now);

  @override
  List<Object?> get props => [
    id,
    word,
    translation,
    sentence,
    createdAt,
    dueAt,
    intervalDays,
    ease,
    reps,
  ];
}
