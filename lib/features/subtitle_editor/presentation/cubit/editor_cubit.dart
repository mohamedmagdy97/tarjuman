import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_timeline.dart';
import 'package:tarjuman/features/player/domain/repositories/subtitle_repository.dart';
import 'package:tarjuman/features/processing/domain/entities/source_language.dart';
import 'package:tarjuman/features/subtitle_editor/domain/cue_reviewer.dart';
import 'package:tarjuman/features/subtitle_editor/domain/usecases/edit_cue_text.dart';
import 'package:tarjuman/features/subtitle_editor/domain/usecases/export_subtitles.dart';
import 'package:tarjuman/features/subtitle_editor/domain/usecases/retranslate_cue.dart';

class EditorState extends Equatable {
  const EditorState({
    this.cues = const [],
    this.query = '',
    this.loading = true,
    this.reviewOnly = false,
    this.issues = const [],
  });

  final List<SubtitleCue> cues;
  final String query;
  final bool loading;

  /// Show only the lines flagged by [CueReviewer].
  final bool reviewOnly;

  /// Issues per cue, parallel to [cues].
  final List<Set<CueIssue>> issues;

  int get flaggedCount => issues.where((s) => s.isNotEmpty).length;

  Set<CueIssue> issuesOf(SubtitleCue cue) {
    final i = cues.indexOf(cue);
    return i < 0 || i >= issues.length ? const {} : issues[i];
  }

  List<SubtitleCue> get visible {
    final q = query.trim().toLowerCase();
    return [
      for (var i = 0; i < cues.length; i++)
        if ((!reviewOnly || (i < issues.length && issues[i].isNotEmpty)) &&
            (q.isEmpty ||
                cues[i].text.toLowerCase().contains(q) ||
                (cues[i].original?.toLowerCase().contains(q) ?? false)))
          cues[i],
    ];
  }

  EditorState copyWith({
    List<SubtitleCue>? cues,
    String? query,
    bool? loading,
    bool? reviewOnly,
    List<Set<CueIssue>>? issues,
  }) => EditorState(
    cues: cues ?? this.cues,
    query: query ?? this.query,
    loading: loading ?? this.loading,
    reviewOnly: reviewOnly ?? this.reviewOnly,
    issues: issues ?? this.issues,
  );

  @override
  List<Object?> get props => [cues, query, loading, reviewOnly, issues];
}

class EditorCubit extends Cubit<EditorState> {
  EditorCubit({
    required this.videoId,
    required SubtitleRepository subtitles,
    required EditCueText edit,
    required ExportSubtitles export,
    RetranslateCue? retranslate,
    SourceLanguage language = SourceLanguage.en,
  }) : _subtitles = subtitles,
       _edit = edit,
       _export = export,
       _retranslate = retranslate,
       _language = language,
       super(const EditorState());

  final String videoId;
  final SubtitleRepository _subtitles;
  final EditCueText _edit;
  final ExportSubtitles _export;
  final RetranslateCue? _retranslate;
  final SourceLanguage _language;

  Future<void> load() async {
    final res = await _subtitles.load(videoId);
    final timeline = res is Success<SubtitleTimeline>
        ? res.value
        : const SubtitleTimeline.empty();
    _setCues(timeline.cues, loading: false);
  }

  final _reviewer = const CueReviewer();

  void _setCues(List<SubtitleCue> cues, {bool? loading}) => emit(
    state.copyWith(
      cues: cues,
      issues: _reviewer.review(cues),
      loading: loading,
    ),
  );

  void toggleReviewOnly() =>
      emit(state.copyWith(reviewOnly: !state.reviewOnly));

  /// Tags a line with a speaker colour (0 clears it).
  Future<void> setSpeaker(SubtitleCue cue, int speaker) async {
    await _subtitles.setSpeaker(videoId, cue.start, speaker);
    _setCues([
      for (final c in state.cues)
        if (c.start == cue.start) c.copyWith(speaker: speaker) else c,
    ]);
  }

  void search(String q) => emit(state.copyWith(query: q));

  Future<void> save(SubtitleCue cue, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed == cue.text) return;
    await _edit(videoId, cue.start, trimmed);
    _setCues([
      for (final c in state.cues)
        if (c.start == cue.start)
          c.copyWith(text: trimmed, status: CueStatus.edited)
        else
          c,
    ]);
  }

  /// Online re-translation of one line; returns the new text on success.
  Future<Result<String>> retranslate(SubtitleCue cue) async {
    final res = await _retranslate!(
      videoId: videoId,
      cue: cue,
      language: _language,
    );
    if (res case Success(:final value)) {
      _setCues([
        for (final c in state.cues)
          if (c.start == cue.start)
            c.copyWith(text: value, status: CueStatus.edited)
          else
            c,
      ]);
    }
    return res;
  }

  bool get canRetranslate => _retranslate != null;

  Future<void> export({required bool includeOriginal}) =>
      _export(videoId, includeOriginal: includeOriginal);
}
