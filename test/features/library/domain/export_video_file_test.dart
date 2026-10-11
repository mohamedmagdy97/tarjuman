import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/ports/media_exporter.dart';
import 'package:tarjuman/features/library/domain/repositories/video_repository.dart';
import 'package:tarjuman/features/library/domain/usecases/export_video_file.dart';

class _Repo extends Mock implements VideoRepository {}

class _Exporter implements MediaExporter {
  _Exporter({this.canSave = true});
  final bool canSave;
  String? savedName;
  String? sharedName;

  @override
  Future<bool> saveToDevice({
    required String path,
    required String name,
  }) async {
    savedName = name;
    return canSave;
  }

  @override
  Future<void> shareFile({required String path, required String name}) async =>
      sharedName = name;
}

void main() {
  late _Repo repo;
  setUp(() {
    repo = _Repo();
    when(() => repo.get('1')).thenAnswer(
      (_) async => Result.success(
        Video(
          id: '1',
          title: 'My: clip?',
          path: '/v/1.mp4',
          createdAt: DateTime(2026),
        ),
      ),
    );
  });

  test('save sanitises the title and keeps the extension', () async {
    final exporter = _Exporter();
    final res = await ExportVideoFile(repo, exporter).save('1');
    expect((res as Success<ExportOutcome>).value, ExportOutcome.savedToDevice);
    expect(exporter.savedName, 'My_ clip_.mp4');
    expect(exporter.sharedName, isNull);
  });

  test('save falls back to the share sheet when the platform cannot', () async {
    final exporter = _Exporter(canSave: false);
    final res = await ExportVideoFile(repo, exporter).save('1');
    expect((res as Success<ExportOutcome>).value, ExportOutcome.shared);
    expect(exporter.sharedName, 'My_ clip_.mp4');
  });

  test('missing video is a storage failure', () async {
    when(() => repo.get('x')).thenAnswer(
      (_) async => const Result.failure(StorageFailure('gone')),
    );
    final res = await ExportVideoFile(repo, _Exporter()).share('x');
    expect((res as Err<ExportOutcome>).failure, isA<StorageFailure>());
  });
}
