import 'package:equatable/equatable.dart';

class GlossaryEntry extends Equatable {
  const GlossaryEntry({
    required this.id,
    required this.term,
    required this.arabic,
  });

  final int id;
  final String term;
  final String arabic;

  @override
  List<Object?> get props => [id, term, arabic];
}
