import 'package:tarjuman/core/result/result.dart';

class PickedFile {
  const PickedFile({required this.path, required this.name});
  final String path;
  final String name;
}

/// Platform file picking. Returns success(null) when the user cancels.
abstract interface class MediaPicker {
  /// [galleryOnly] = the system photo/video picker (no permission needed);
  /// otherwise any file from the system file browser.
  Future<Result<PickedFile?>> pickVideo({bool galleryOnly = false});
  Future<Result<PickedFile?>> pickSubtitle();
}
