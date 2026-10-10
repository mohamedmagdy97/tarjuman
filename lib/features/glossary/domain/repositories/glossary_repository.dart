import 'package:tarjuman/features/glossary/domain/entities/glossary_entry.dart';

abstract interface class GlossaryRepository {
  Stream<List<GlossaryEntry>> watchAll();
  Future<List<GlossaryEntry>> all();
  Future<void> add(String term, String arabic);
  Future<void> remove(int id);
}
