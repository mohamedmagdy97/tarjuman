import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/ports/media_picker.dart';

abstract interface class FileDownloader {
  /// Streams a direct file link to temp storage. [onProgress] gets 0..1, or
  /// null when the server doesn't report a length.
  Future<Result<PickedFile>> download(
    Uri url, {
    void Function(double? fraction)? onProgress,
    CancelToken? cancel,
  });
}
