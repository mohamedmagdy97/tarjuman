import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/data/links/link_exceptions.dart';
import 'package:tarjuman/features/library/domain/ports/file_downloader.dart';
import 'package:tarjuman/features/library/domain/ports/link_source.dart';
import 'package:tarjuman/features/library/domain/ports/media_picker.dart';

/// Writes any [LinkSource] to a temp file, honouring cancellation.
class HttpFileDownloader implements FileDownloader {
  @override
  Future<Result<PickedFile>> download(
    LinkSource source, {
    void Function(double? fraction)? onProgress,
    CancelToken? cancel,
  }) async {
    IOSink? sink;
    File? target;
    try {
      final dir = await getTemporaryDirectory();
      final name = '${_safe(source.title)}.${source.extension}';
      target = File(
        p.join(dir.path, 'dl_${DateTime.now().millisecondsSinceEpoch}_$name'),
      );
      sink = target.openWrite();
      await for (final chunk in source.open(onProgress ?? (_) {})) {
        if (cancel?.isCancelled ?? false) {
          await sink.close();
          await target.delete();
          return const Result.failure(CancelledFailure());
        }
        sink.add(chunk);
      }
      await sink.close();
      return Result.success(PickedFile(path: target.path, name: name));
    } on HttpStatusException catch (e) {
      await _discard(sink, target);
      return Result.failure(
        e.status == 404 || e.status == 410
            ? NoVideoFoundFailure(e.toString())
            : e.status >= 500
            ? NetworkFailure(e.toString())
            : SiteRefusedFailure(e.toString()),
      );
    } on HandshakeException {
      await _discard(sink, target);
      return const Result.failure(NetworkFailure('Secure connection failed'));
    } on FormatException catch (e) {
      await _discard(sink, target);
      return Result.failure(UnsupportedMediaFailure(e.message));
    } on SocketException {
      await _discard(sink, target);
      return const Result.failure(NetworkFailure());
    } on http.ClientException catch (e) {
      await _discard(sink, target);
      return Result.failure(NetworkFailure(e.message));
    } on FileSystemException catch (e) {
      await _discard(sink, target);
      return Result.failure(StorageFailure(e.message));
    } on Object catch (e) {
      await _discard(sink, target);
      return Result.failure(NetworkFailure(e.toString()));
    }
  }

  Future<void> _discard(IOSink? sink, File? file) async {
    try {
      await sink?.close();
      if (file != null && file.existsSync()) await file.delete();
    } on Object {
      // Best effort: the temp dir is cleaned from the storage screen too.
    }
  }

  String _safe(String s) {
    final cleaned = s.replaceAll(RegExp(r'[\\/:*?"<>|\n\r]'), '_').trim();
    final cut = cleaned.length > 60 ? cleaned.substring(0, 60) : cleaned;
    return cut.isEmpty ? 'video' : cut;
  }
}
