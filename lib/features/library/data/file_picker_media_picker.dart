import 'package:file_picker/file_picker.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/ports/media_picker.dart';

class FilePickerMediaPicker implements MediaPicker {
  @override
  Future<Result<PickedFile?>> pickVideo() => _pick(FileType.video);

  @override
  Future<Result<PickedFile?>> pickSubtitle() => _pick(
    FileType.custom,
    extensions: const ['srt', 'vtt'],
  );

  Future<Result<PickedFile?>> _pick(
    FileType type, {
    List<String>? extensions,
  }) async {
    try {
      final file = await FilePicker.pickFile(
        type: type,
        allowedExtensions: extensions,
      );
      if (file == null || file.path == null) return const Result.success(null);
      return Result.success(PickedFile(path: file.path!, name: file.name));
    } on Exception catch (e) {
      return Result.failure(StorageFailure(e.toString()));
    }
  }
}
