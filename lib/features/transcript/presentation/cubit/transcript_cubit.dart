import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_timeline.dart';
import 'package:tarjuman/features/player/domain/repositories/subtitle_repository.dart';
import 'package:tarjuman/features/player/domain/services/subtitle_serializer.dart';
import 'package:tarjuman/features/transcript/domain/usecases/export_transcript.dart';

class TranscriptState extends Equatable {
  const TranscriptState({this.cues = const [], this.loading = true});
  final List<SubtitleCue> cues;
  final bool loading;

  @override
  List<Object?> get props => [cues, loading];
}

class TranscriptCubit extends Cubit<TranscriptState> {
  TranscriptCubit({
    required this.videoId,
    required SubtitleRepository subtitles,
    required SubtitleSerializer serializer,
    required ExportTranscript export,
  }) : _subtitles = subtitles,
       _serializer = serializer,
       _export = export,
       super(const TranscriptState());

  final String videoId;
  final SubtitleRepository _subtitles;
  final SubtitleSerializer _serializer;
  final ExportTranscript _export;

  Future<void> load() async {
    final res = await _subtitles.load(videoId);
    emit(
      TranscriptState(
        cues: res is Success<SubtitleTimeline> ? res.value.cues : const [],
        loading: false,
      ),
    );
  }

  /// Plain text for the clipboard.
  String text({required bool includeOriginal}) => _serializer.toText(
    SubtitleTimeline(state.cues),
    includeOriginal: includeOriginal,
  );

  Future<void> share({required bool includeOriginal}) =>
      _export(videoId, includeOriginal: includeOriginal);
}
