import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/ports/file_downloader.dart';
import 'package:tarjuman/features/library/domain/ports/media_picker.dart';

class HttpFileDownloader implements FileDownloader {
  @override
  Future<Result<PickedFile>> download(
    Uri url, {
    void Function(double? fraction)? onProgress,
    CancelToken? cancel,
  }) async {
    final client = http.Client();
    IOSink? sink;
    File? target;
    try {
      final res = await client.send(http.Request('GET', url));
      final type = res.headers['content-type'] ?? '';
      if (res.statusCode != 200 || type.startsWith('text/html')) {
        return const Result.failure(NetworkFailure('Not a direct file link'));
      }
      final name = _fileName(url, res.headers['content-disposition']);
      final dir = await getTemporaryDirectory();
      target = File(
        p.join(dir.path, 'dl_${DateTime.now().millisecondsSinceEpoch}_$name'),
      );
      sink = target.openWrite();

      final total = res.contentLength;
      var received = 0;
      await for (final chunk in res.stream) {
        if (cancel?.isCancelled ?? false) {
          await sink.close();
          await target.delete();
          return const Result.failure(CancelledFailure());
        }
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(total == null || total == 0 ? null : received / total);
      }
      await sink.close();
      return Result.success(PickedFile(path: target.path, name: name));
    } on SocketException {
      return const Result.failure(NetworkFailure());
    } on http.ClientException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on FileSystemException catch (e) {
      return Result.failure(StorageFailure(e.message));
    } finally {
      client.close();
    }
  }

  String _fileName(Uri url, String? disposition) {
    final fromHeader = RegExp(
      r'filename\*?=(?:UTF-8\x27\x27)?"?([^";]+)"?',
    ).firstMatch(disposition ?? '')?.group(1);
    final raw =
        fromHeader ??
        (url.pathSegments.isNotEmpty ? url.pathSegments.last : 'video');
    final decoded = Uri.decodeComponent(raw);
    return decoded.isEmpty ? 'video' : decoded;
  }
}
