import 'package:tarjuman/features/player/domain/entities/cue_hit.dart';
import 'package:tarjuman/features/player/domain/repositories/subtitle_repository.dart';

class SearchSubtitles {
  const SearchSubtitles(this._subtitles);
  final SubtitleRepository _subtitles;

  Future<List<CueHit>> call(String query) {
    final q = query.trim();
    return q.length < 2 ? Future.value(const []) : _subtitles.search(q);
  }
}
