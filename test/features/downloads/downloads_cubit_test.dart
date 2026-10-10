import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/downloads/presentation/cubit/downloads_cubit.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/usecases/import_from_url.dart';

class _MockImport extends Mock implements ImportFromUrl {}

void main() {
  late _MockImport import;
  setUp(() => import = _MockImport());

  void stub(String url, Future<Result<Video>> Function() answer) => when(
    () => import(
      url,
      referer: any(named: 'referer'),
      onProgress: any(named: 'onProgress'),
      cancel: any(named: 'cancel'),
    ),
  ).thenAnswer((_) => answer());

  Video video(String id) => Video(
    id: id,
    title: 'T$id',
    path: '/$id',
    createdAt: DateTime(2026),
  );

  test('runs two at a time, queues the rest, and finishes them all', () async {
    final gates = {
      for (final u in ['a', 'b', 'c']) u: Completer<Result<Video>>(),
    };
    for (final e in gates.entries) {
      stub(e.key, () => e.value.future);
    }
    final cubit = DownloadsCubit(import)
      ..add([
        for (final u in gates.keys) DownloadRequest(url: u),
      ]);
    await Future<void>.delayed(Duration.zero);
    expect(
      cubit.state.tasks.map((t) => t.status),
      [DownloadStatus.running, DownloadStatus.running, DownloadStatus.queued],
    );

    gates['a']!.complete(Result.success(video('1')));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.tasks[0].status, DownloadStatus.done);
    expect(cubit.state.tasks[2].status, DownloadStatus.running);

    gates['b']!.complete(const Result.failure(SiteRefusedFailure('HTTP 403')));
    gates['c']!.complete(Result.success(video('3')));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.tasks[1].status, DownloadStatus.failed);
    expect(cubit.state.tasks[1].failure, isA<SiteRefusedFailure>());
    expect(cubit.state.active, 0);
    await cubit.close();
  });

  test(
    'duplicate active request is ignored; retry re-queues a failure',
    () async {
      stub('x', () async => const Result.failure(NoVideoFoundFailure()));
      final cubit = DownloadsCubit(import)
        ..add(const [DownloadRequest(url: 'x')])
        ..add(const [DownloadRequest(url: 'x')]);
      expect(cubit.state.tasks, hasLength(1));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.tasks.single.status, DownloadStatus.failed);

      stub('x', () async => Result.success(video('9')));
      cubit.retry(cubit.state.tasks.single.id);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.tasks.single.status, DownloadStatus.done);
      cubit.clearFinished();
      expect(cubit.state.tasks, isEmpty);
      await cubit.close();
    },
  );

  test('cancelling a running download removes it', () async {
    final gate = Completer<Result<Video>>();
    stub('slow', () => gate.future);
    final cubit = DownloadsCubit(import)
      ..add(const [DownloadRequest(url: 'slow')]);
    await Future<void>.delayed(Duration.zero);
    cubit.cancel(cubit.state.tasks.single.id);
    gate.complete(const Result.failure(CancelledFailure()));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.tasks, isEmpty);
    await cubit.close();
  });
}
