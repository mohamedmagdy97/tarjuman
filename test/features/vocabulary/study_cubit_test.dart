import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarjuman/core/database/app_database.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/vocabulary/data/vocabulary_repository_impl.dart';
import 'package:tarjuman/features/vocabulary/domain/ports/word_translator.dart';
import 'package:tarjuman/features/vocabulary/presentation/cubit/study_cubit.dart';

class _Translator implements WordTranslator {
  _Translator({this.fail = false});
  final bool fail;
  @override
  Future<Result<String>> translate(String word) async => fail
      ? const Result.failure(ModelMissingFailure('translation'))
      : Result.success('ar:$word');
}

void main() {
  late AppDatabase db;
  late VocabularyRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = VocabularyRepositoryImpl(db);
  });
  tearDown(() => db.close());

  test('strips punctuation, translates and saves once', () async {
    final cubit = StudyCubit(_Translator(), repo);
    await cubit.selectWord('Hello,', sentence: 'Hello, world.');
    expect(cubit.state.word, 'Hello');
    expect(cubit.state.translation, 'ar:Hello');
    expect(cubit.state.saved, isFalse);

    await cubit.save();
    await cubit.save(); // second tap is a no-op
    expect(cubit.state.saved, isTrue);
    final words = await repo.watchAll().first;
    expect(words, hasLength(1));
    expect(words.single.word, 'hello');
    expect(words.single.sentence, 'Hello, world.');
    await cubit.close();
  });

  test('already saved words are flagged saved on selection', () async {
    await repo.add(word: 'world', translation: 'x');
    final cubit = StudyCubit(_Translator(), repo);
    await cubit.selectWord('WORLD!', sentence: 's');
    expect(cubit.state.saved, isTrue);
    await cubit.close();
  });

  test('missing model surfaces a failure instead of a translation', () async {
    final cubit = StudyCubit(_Translator(fail: true), repo);
    await cubit.selectWord('hello', sentence: 's');
    expect(cubit.state.translation, isNull);
    expect(cubit.state.failure, isA<ModelMissingFailure>());
    await cubit.close();
  });

  test('punctuation-only taps are ignored', () async {
    final cubit = StudyCubit(_Translator(), repo);
    await cubit.selectWord('...', sentence: 's');
    expect(cubit.state.word, isNull);
    await cubit.close();
  });
}
