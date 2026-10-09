import 'package:tarjuman/core/result/result.dart';

class PickedFile {
  const PickedFile({required this.path, required this.name});
  final String path;
  final String name;
}

/// Platform file picking. Returns success(null) when the user cancels.
abstract interface class MediaPicker {
  Future<Result<PickedFile?>> pickVideo();
  Future<Result<PickedFile?>> pickSubtitle();
}
