import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/usecases/delete_video.dart';
import 'package:tarjuman/features/library/domain/usecases/import_video.dart';
import 'package:tarjuman/features/library/domain/usecases/watch_library.dart';
import 'package:tarjuman/features/library/presentation/cubit/library_cubit.dart';

class _MockWatch extends Mock implements WatchLibrary {}

class _MockImport extends Mock implements ImportVideo {}

class _MockDelete extends Mock implements DeleteVideo {}

Video video(String id, VideoStatus s) => Video(
  id: id,
  title: id,
  path: '/$id',
  createdAt: DateTime(2026),
  status: s,
);

void main() {
  late _MockWatch watch;
  late _MockImport import;
  late StreamController<List<Video>> stream;

  setUp(() {
    watch = _MockWatch();
    import = _MockImport();
    stream = StreamController<List<Video>>();
    when(() => watch()).thenAnswer((_) => stream.stream);
  });
  tearDown(() => stream.close());

  LibraryCubit build() => LibraryCubit(watch, import, _MockDelete());

  blocTest<LibraryCubit, LibraryState>(
    'emits videos once the stream delivers and stops loading',
    build: build,
    act: (_) => stream.add([video('a', VideoStatus.ready)]),
    expect: () => [
      isA<LibraryState>()
          .having((s) => s.loading, 'loading', false)
          .having((s) => s.videos.length, 'videos', 1),
    ],
  );

  blocTest<LibraryCubit, LibraryState>(
    'filter ready hides imported videos',
    build: build,
    act: (c) {
      stream.add([
        video('a', VideoStatus.ready),
        video('b', VideoStatus.imported),
      ]);
      c.setFilter(LibraryFilter.ready);
    },
    verify: (c) => expect(c.state.visible.map((v) => v.id), ['a']),
  );

  blocTest<LibraryCubit, LibraryState>(
    'surfaces import failure then clears it',
    build: build,
    setUp: () => when(() => import()).thenAnswer(
      (_) async => const Result<Video?>.failure(StorageFailure()),
    ),
    act: (c) async {
      await c.importVideo();
      c.failureShown();
    },
    verify: (c) {
      expect(c.state.failure, isNull);
      expect(c.state.importing, isFalse);
    },
  );
}
