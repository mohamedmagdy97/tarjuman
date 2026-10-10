import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';
import 'package:tarjuman/features/library/domain/usecases/import_shared_media.dart';
import 'package:tarjuman/features/processing/domain/ports/audio_extractor.dart';

class _Repo extends Mock implements VideoRepository {}

class _Probe extends Mock implements AudioExtractor {}

void main() {
  late _Repo repo;
  late _Probe probe;
  late ImportSharedMedia useCase;

  setUp(() {
    repo = _Repo();
    probe = _Probe();
    useCase = ImportSharedMedia(repo, probe);
  });

  test('adds a readable shared file with its duration', () async {
    when(() => probe.probeDuration('/c/in.mp4')).thenAnswer(
      (_) async => const Result.success(Duration(seconds: 42)),
    );
    final video = Video(
      id: '1',
      title: 'in.mp4',
      path: '/c/in.mp4',
      createdAt: DateTime(2026),
    );
    when(
      () => repo.add(
        title: 'in.mp4',
        path: '/c/in.mp4',
        duration: const Duration(seconds: 42),
      ),
    ).thenAnswer((_) async => Result.success(video));

    final res = await useCase(path: '/c/in.mp4', name: 'in.mp4');

    expect((res as Success<Video>).value.id, '1');
  });

  test('rejects a file FFmpeg cannot read', () async {
    when(() => probe.probeDuration('/c/x.pdf')).thenAnswer(
      (_) async => const Result.failure(UnsupportedMediaFailure()),
    );

    final res = await useCase(path: '/c/x.pdf', name: 'x.pdf');

    expect((res as Err<Video>).failure, isA<UnsupportedMediaFailure>());
    verifyNever(
      () => repo.add(
        title: any(named: 'title'),
        path: any(named: 'path'),
        duration: any(named: 'duration'),
      ),
    );
  });
}
