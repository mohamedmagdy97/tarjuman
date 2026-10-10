import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/vocabulary/domain/ports/word_translator.dart';
import 'package:tarjuman/features/vocabulary/domain/repositories/vocabulary_repository.dart';

class StudyState extends Equatable {
  const StudyState({
    this.word,
    this.translation,
    this.loading = false,
    this.saved = false,
    this.failure,
  });

  final String? word;
  final String? translation;
  final bool loading;
  final bool saved;
  final Failure? failure;

  @override
  List<Object?> get props => [
    word,
    translation,
    loading,
    saved,
    failure?.runtimeType,
  ];
}

class StudyCubit extends Cubit<StudyState> {
  StudyCubit(this._translator, this._vocab) : super(const StudyState());

  final WordTranslator _translator;
  final VocabularyRepository _vocab;
  String? _sentence;

  /// Strips punctuation and translates one tapped word.
  Future<void> selectWord(String raw, {required String sentence}) async {
    final word = raw.replaceAll(RegExp(r"[^\p{L}\p{N}'’-]", unicode: true), '');
    if (word.isEmpty) return;
    _sentence = sentence;
    emit(
      StudyState(word: word, loading: true, saved: await _vocab.contains(word)),
    );
    final res = await _translator.translate(word);
    emit(
      switch (res) {
        Success(:final value) => StudyState(
          word: word,
          translation: value,
          saved: state.saved,
        ),
        Err(:final failure) => StudyState(word: word, failure: failure),
      },
    );
  }

  /// Saves the whole sentence as a card (English -> Arabic translation).
  Future<void> saveSentence(String english, String arabic) async {
    if (english.trim().isEmpty || arabic.trim().isEmpty) return;
    await _vocab.add(word: english.trim(), translation: arabic.trim());
  }

  Future<void> save() async {
    final w = state.word;
    final t = state.translation;
    if (w == null || t == null || state.saved) return;
    await _vocab.add(word: w, translation: t, sentence: _sentence);
    emit(
      StudyState(word: w, translation: t, saved: true),
    );
  }
}
