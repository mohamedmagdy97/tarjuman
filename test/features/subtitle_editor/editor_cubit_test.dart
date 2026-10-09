// SubtitleCue asserts end > start, which cannot be const-evaluated.
// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_timeline.dart';
import 'package:tarjuman/features/player/domain/repositories/subtitle_repository.dart';
import 'package:tarjuman/features/subtitle_editor/domain/usecases/edit_cue_text.dart';
import 'package:tarjuman/features/subtitle_editor/domain/usecases/export_subtitles.dart';
import 'package:tarjuman/features/subtitle_editor/presentation/cubit/editor_cubit.dart';

class _Repo extends Mock implements SubtitleRepository {}

class _Export extends Mock implements ExportSubtitles {}

void main() {
  late _Repo repo;
  late EditorCubit cubit;
  final a = SubtitleCue(
    start: Duration(seconds: 1),
    end: Duration(seconds: 3),
    text: 'مرحبا',
    original: 'Hello',
  );
  final b = SubtitleCue(
    start: Duration(seconds: 4),
    end: Duration(seconds: 6),
    text: 'شكرا',
    original: 'Thanks',
  );

  setUpAll(() => registerFallbackValue(Duration.zero));

  setUp(() async {
    repo = _Repo();
    when(
      () => repo.load('v'),
    ).thenAnswer((_) async => Result.success(SubtitleTimeline([a, b])));
    when(
      () => repo.updateText('v', any(), any()),
    ).thenAnswer((_) async => const Result.success(null));
    cubit = EditorCubit(
      videoId: 'v',
      subtitles: repo,
      edit: EditCueText(repo),
      export: _Export(),
    );
    await cubit.load();
  });
  tearDown(() => cubit.close());

  test('search matches Arabic and English text', () {
    cubit.search('thank');
    expect(cubit.state.visible.map((c) => c.text), ['شكرا']);
    cubit.search('مرح');
    expect(cubit.state.visible.map((c) => c.text), ['مرحبا']);
    cubit.search('');
    expect(cubit.state.visible, hasLength(2));
  });

  test('saving an edit persists it and marks the cue edited', () async {
    await cubit.save(a, '  أهلاً  ');
    verify(() => repo.updateText('v', a.start, 'أهلاً')).called(1);
    final edited = cubit.state.cues.first;
    expect(edited.text, 'أهلاً');
    expect(edited.status, CueStatus.edited);
    expect(edited.original, 'Hello');
  });

  test('unchanged or empty edits are ignored', () async {
    await cubit.save(a, 'مرحبا');
    await cubit.save(a, '   ');
    verifyNever(() => repo.updateText(any(), any(), any()));
  });
}
