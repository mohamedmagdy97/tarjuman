import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/ports/media_picker.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';
import 'package:tarjuman/features/library/domain/usecases/import_video.dart';
import 'package:tarjuman/features/processing/domain/ports/audio_extractor.dart';

class _Picker extends Mock implements MediaPicker {}

class _Repo extends Mock implements VideoRepository {}

class _Probe extends Mock implements AudioExtractor {}

void main() {
  late _Picker picker;
  late _Repo repo;
  late _Probe probe;
  late ImportVideo import;

  setUp(() {
    picker = _Picker();
    repo = _Repo();
    probe = _Probe();
    import = ImportVideo(picker, repo, probe);
  });

  Video video() =>
      Video(id: '1', title: 'x.avi', path: '/x.avi', createdAt: DateTime(2026));

  test('accepts any extension when FFmpeg can read the file', () async {
    when(() => picker.pickVideo()).thenAnswer(
      (_) async =>
          const Result.success(PickedFile(path: '/c/x.avi', name: 'x.avi')),
    );
    when(
      () => probe.probeDuration('/c/x.avi'),
    ).thenAnswer((_) async => const Result.success(Duration(minutes: 2)));
    when(
      () => repo.add(
        title: 'x.avi',
        path: '/c/x.avi',
        duration: const Duration(minutes: 2),
      ),
    ).thenAnswer((_) async => Result.success(video()));

    final res = await import();

    expect((res as Success<Video?>).value?.id, '1');
  });

  test('rejects unreadable files without adding them', () async {
    when(() => picker.pickVideo()).thenAnswer(
      (_) async =>
          const Result.success(PickedFile(path: '/c/a.pdf', name: 'a.pdf')),
    );
    when(() => probe.probeDuration('/c/a.pdf')).thenAnswer(
      (_) async => const Result.failure(UnsupportedMediaFailure()),
    );

    final res = await import();

    expect((res as Err<Video?>).failure, isA<UnsupportedMediaFailure>());
    verifyNever(
      () => repo.add(
        title: any(named: 'title'),
        path: any(named: 'path'),
      ),
    );
  });

  test('cancelling the picker returns null and does not probe', () async {
    when(
      () => picker.pickVideo(),
    ).thenAnswer((_) async => const Result.success(null));
    final res = await import();
    expect((res as Success<Video?>).value, isNull);
    verifyNever(() => probe.probeDuration(any()));
  });
}
