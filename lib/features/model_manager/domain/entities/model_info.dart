import 'package:equatable/equatable.dart';

enum ModelKind { speech, translation }

class ModelInfo extends Equatable {
  const ModelInfo({
    required this.id,
    required this.kind,
    required this.name,
    required this.sizeBytes,
    required this.installed,
  });

  final String id;
  final ModelKind kind;
  final String name;
  final int sizeBytes;
  final bool installed;

  @override
  List<Object?> get props => [id, kind, name, sizeBytes, installed];
}
