enum ReviewGrade { again, hard, good, easy }

class CardSchedule {
  const CardSchedule({
    required this.dueAt,
    required this.intervalDays,
    required this.ease,
    required this.reps,
  });

  final DateTime dueAt;
  final int intervalDays;
  final double ease;
  final int reps;
}

/// Simplified SM-2: intervals grow with each successful review, a lapse
/// resets them.
class SpacedRepetition {
  const SpacedRepetition();

  static const _minEase = 1.3;

  CardSchedule next({
    required int intervalDays,
    required double ease,
    required int reps,
    required ReviewGrade grade,
    required DateTime now,
  }) {
    switch (grade) {
      case ReviewGrade.again:
        return CardSchedule(
          dueAt: now.add(const Duration(minutes: 10)),
          intervalDays: 0,
          ease: (ease - 0.2).clamp(_minEase, 3.0),
          reps: 0,
        );
      case ReviewGrade.hard:
        final days = intervalDays == 0
            ? 1
            : (intervalDays * 1.2).round().clamp(1, 3650);
        return _due(now, days, (ease - 0.15).clamp(_minEase, 3.0), reps + 1);
      case ReviewGrade.good:
        final days = switch (reps) {
          0 => 1,
          1 => 3,
          _ => (intervalDays * ease).round().clamp(1, 3650),
        };
        return _due(now, days, ease, reps + 1);
      case ReviewGrade.easy:
        final days = reps == 0
            ? 3
            : (intervalDays * ease * 1.3).round().clamp(1, 3650);
        return _due(now, days, (ease + 0.15).clamp(_minEase, 3.0), reps + 1);
    }
  }

  CardSchedule _due(DateTime now, int days, double ease, int reps) =>
      CardSchedule(
        dueAt: now.add(Duration(days: days)),
        intervalDays: days,
        ease: ease,
        reps: reps,
      );
}
