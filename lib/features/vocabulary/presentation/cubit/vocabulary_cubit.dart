import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/features/vocabulary/domain/entities/vocab_word.dart';
import 'package:tarjuman/features/vocabulary/domain/repositories/vocabulary_repository.dart';

class VocabularyState extends Equatable {
  const VocabularyState({this.words = const [], this.loading = true});
  final List<VocabWord> words;
  final bool loading;

  @override
  List<Object?> get props => [words, loading];
}

class VocabularyCubit extends Cubit<VocabularyState> {
  VocabularyCubit(this._repo) : super(const VocabularyState()) {
    _sub = _repo.watchAll().listen(
      (w) => emit(VocabularyState(words: w, loading: false)),
    );
  }

  final VocabularyRepository _repo;
  late final StreamSubscription<List<VocabWord>> _sub;

  Future<void> remove(int id) => _repo.remove(id);

  @override
  Future<void> close() {
    unawaited(_sub.cancel());
    return super.close();
  }
}
