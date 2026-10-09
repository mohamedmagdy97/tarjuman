import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_timeline.dart';
import 'package:tarjuman/features/player/domain/repositories/subtitle_repository.dart';
import 'package:tarjuman/features/subtitle_editor/domain/usecases/edit_cue_text.dart';
import 'package:tarjuman/features/subtitle_editor/domain/usecases/export_subtitles.dart';

class EditorState extends Equatable {
  const EditorState({
    this.cues = const [],
    this.query = '',
    this.loading = true,
  });

  final List<SubtitleCue> cues;
  final String query;
  final bool loading;

  List<SubtitleCue> get visible {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return cues;
    return cues
        .where(
          (c) =>
              c.text.toLowerCase().contains(q) ||
              (c.original?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  EditorState copyWith({
    List<SubtitleCue>? cues,
    String? query,
    bool? loading,
  }) => EditorState(
    cues: cues ?? this.cues,
    query: query ?? this.query,
    loading: loading ?? this.loading,
  );

  @override
  List<Object?> get props => [cues, query, loading];
}

class EditorCubit extends Cubit<EditorState> {
  EditorCubit({
    required this.videoId,
    required SubtitleRepository subtitles,
    required EditCueText edit,
    required ExportSubtitles export,
  }) : _subtitles = subtitles,
       _edit = edit,
       _export = export,
       super(const EditorState());

  final String videoId;
  final SubtitleRepository _subtitles;
  final EditCueText _edit;
  final ExportSubtitles _export;

  Future<void> load() async {
    final res = await _subtitles.load(videoId);
    final timeline = res is Success<SubtitleTimeline>
        ? res.value
        : const SubtitleTimeline.empty();
    emit(state.copyWith(cues: timeline.cues, loading: false));
  }

  void search(String q) => emit(state.copyWith(query: q));

  Future<void> save(SubtitleCue cue, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed == cue.text) return;
    await _edit(videoId, cue.start, trimmed);
    emit(
      state.copyWith(
        cues: [
          for (final c in state.cues)
            if (c.start == cue.start)
              SubtitleCue(
                start: c.start,
                end: c.end,
                text: trimmed,
                original: c.original,
                status: CueStatus.edited,
              )
            else
              c,
        ],
      ),
    );
  }

  Future<void> export({required bool includeOriginal}) =>
      _export(videoId, includeOriginal: includeOriginal);
}
