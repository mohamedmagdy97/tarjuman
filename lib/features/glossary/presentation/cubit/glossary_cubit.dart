import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/features/glossary/domain/entities/glossary_entry.dart';
import 'package:tarjuman/features/glossary/domain/repositories/glossary_repository.dart';

class GlossaryState extends Equatable {
  const GlossaryState({this.entries = const [], this.loading = true});
  final List<GlossaryEntry> entries;
  final bool loading;

  @override
  List<Object?> get props => [entries, loading];
}

class GlossaryCubit extends Cubit<GlossaryState> {
  GlossaryCubit(this._repo, {this.videoId}) : super(const GlossaryState()) {
    _sub = _repo
        .watch(videoId: videoId)
        .listen(
          (e) => emit(GlossaryState(entries: e, loading: false)),
        );
  }

  final GlossaryRepository _repo;

  /// Null = the global glossary; otherwise terms for this video only.
  final String? videoId;
  late final StreamSubscription<List<GlossaryEntry>> _sub;

  Future<void> add(String term, String arabic) async {
    if (term.trim().isEmpty || arabic.trim().isEmpty) return;
    await _repo.add(term, arabic, videoId: videoId);
  }

  Future<void> remove(int id) => _repo.remove(id);

  @override
  Future<void> close() {
    unawaited(_sub.cancel());
    return super.close();
  }
}
