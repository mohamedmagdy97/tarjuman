import 'package:equatable/equatable.dart';

enum ModelKind { speech, translation }

class ModelInfo extends Equatable {
  const ModelInfo({
    required this.id,
    required this.kind,
    required this.name,
    required this.sizeBytes,
    required this.installed,
    this.languageCode,
    this.multilingual = false,
    this.recommended = false,
  });

  final String id;
  final ModelKind kind;
  final String name;
  final int sizeBytes;
  final bool installed;

  /// Translation models: the language they cover. Speech: null.
  final String? languageCode;

  /// Speech models that understand languages other than English.
  final bool multilingual;

  /// Best fit for this device (decided from its RAM).
  final bool recommended;

  @override
  List<Object?> get props => [
    id,
    kind,
    name,
    sizeBytes,
    installed,
    languageCode,
    multilingual,
    recommended,
  ];
}
