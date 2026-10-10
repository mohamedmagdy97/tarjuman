import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarjuman/core/database/app_database.dart';
import 'package:tarjuman/features/vocabulary/data/vocabulary_repository_impl.dart';
import 'package:tarjuman/features/vocabulary/domain/services/spaced_repetition.dart';
import 'package:tarjuman/features/vocabulary/domain/usecases/export_vocabulary.dart';
import 'package:tarjuman/features/vocabulary/presentation/cubit/review_cubit.dart';

void main() {
  final now = DateTime(2026, 10, 10, 12);
  const srs = SpacedRepetition();

  CardSchedule next(int interval, double ease, int reps, ReviewGrade g) =>
      srs.next(
        intervalDays: interval,
        ease: ease,
        reps: reps,
        grade: g,
        now: now,
      );

  test('first good reviews climb 1 -> 3 -> ease-scaled days', () {
    final a = next(0, 2.5, 0, ReviewGrade.good);
    expect(a.intervalDays, 1);
    final b = next(a.intervalDays, a.ease, a.reps, ReviewGrade.good);
    expect(b.intervalDays, 3);
    final c = next(b.intervalDays, b.ease, b.reps, ReviewGrade.good);
    expect(c.intervalDays, 8); // 3 * 2.5 rounded
    expect(c.dueAt, now.add(const Duration(days: 8)));
  });

  test(
    'again resets progress, retries in 10 minutes, lowers ease to a floor',
    () {
      final r = next(20, 1.4, 5, ReviewGrade.again);
      expect(r.reps, 0);
      expect(r.intervalDays, 0);
      expect(r.dueAt, now.add(const Duration(minutes: 10)));
      expect(r.ease, 1.3);
    },
  );

  test('easy grows faster than good and raises ease', () {
    final good = next(10, 2.5, 3, ReviewGrade.good);
    final easy = next(10, 2.5, 3, ReviewGrade.easy);
    expect(easy.intervalDays, greaterThan(good.intervalDays));
    expect(easy.ease, greaterThan(2.5));
  });

  test('review queue: grading removes a card, again re-queues it', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = VocabularyRepositoryImpl(db);
    await repo.add(word: 'alpha', translation: 'أ');
    await repo.add(word: 'beta', translation: 'ب');
    final cubit = ReviewCubit(repo, srs, clock: () => now);
    await cubit.load();
    expect(cubit.state.queue, hasLength(2));

    final first = cubit.state.current!;
    await cubit.grade(ReviewGrade.again);
    expect(cubit.state.queue, hasLength(2)); // came back at the end
    expect(cubit.state.current!.id, isNot(first.id));

    await cubit.grade(ReviewGrade.good);
    expect(cubit.state.reviewed, 1);

    // The graded card is no longer due when the queue is rebuilt.
    final fresh = ReviewCubit(repo, srs, clock: () => now);
    await fresh.load();
    expect(fresh.state.queue.map((w) => w.word), isNot(contains('beta')));
    await cubit.close();
    await fresh.close();
  });

  test('CSV export quotes commas and doubles quotes', () {
    final csv = ExportVocabulary.csv([
      ('hello', 'مرحبا', 'Say "hello", please'),
    ]);
    expect(csv, '"hello","مرحبا","Say ""hello"", please"');
  });
}
