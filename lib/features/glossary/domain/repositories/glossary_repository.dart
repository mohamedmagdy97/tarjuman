import 'package:tarjuman/features/glossary/domain/entities/glossary_entry.dart';

abstract interface class GlossaryRepository {
  /// The entries of one scope: global ones when [videoId] is null, otherwise
  /// only that video's own terms.
  Stream<List<GlossaryEntry>> watch({String? videoId});

  /// Everything that applies while translating [videoId]: its own terms
  /// first, then the global ones.
  Future<List<GlossaryEntry>> effective({String? videoId});

  Future<void> add(String term, String arabic, {String? videoId});
  Future<void> remove(int id);
}
