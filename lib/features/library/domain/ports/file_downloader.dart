import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/ports/link_source.dart';
import 'package:tarjuman/features/library/domain/ports/media_picker.dart';

abstract interface class FileDownloader {
  /// Saves [source] to temp storage. [onProgress] gets 0..1, or null when
  /// the length is unknown.
  Future<Result<PickedFile>> download(
    LinkSource source, {
    void Function(double? fraction)? onProgress,
    CancelToken? cancel,
  });
}
