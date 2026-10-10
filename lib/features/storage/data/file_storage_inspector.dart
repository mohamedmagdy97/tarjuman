import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/storage/domain/entities/storage_usage.dart';
import 'package:tarjuman/features/storage/domain/ports/storage_inspector.dart';

class FileStorageInspector implements StorageInspector {
  Future<int> _dirBytes(Directory d) async {
    if (!d.existsSync()) return 0;
    var total = 0;
    await for (final e in d.list(recursive: true, followLinks: false)) {
      if (e is File) {
        try {
          total += await e.length();
        } on FileSystemException {
          continue;
        }
      }
    }
    return total;
  }

  Future<List<Directory>> _tempDirs() async {
    final cache = await getTemporaryDirectory();
    return [
      Directory(p.join(cache.path, 'work')),
      Directory(p.join(cache.path, 'incoming')),
    ];
  }

  @override
  Future<StorageUsage> measure(List<Video> videos) async {
    final support = await getApplicationSupportDirectory();
    final usage = <VideoUsage>[];
    for (final v in videos) {
      final f = File(v.path);
      if (f.existsSync()) {
        usage.add(
          VideoUsage(id: v.id, title: v.title, bytes: await f.length()),
        );
      }
    }
    usage.sort((a, b) => b.bytes.compareTo(a.bytes));
    var temp = 0;
    for (final d in await _tempDirs()) {
      temp += await _dirBytes(d);
    }
    // Interrupted link downloads live directly in the cache dir.
    final cache = await getTemporaryDirectory();
    if (cache.existsSync()) {
      for (final e in cache.listSync()) {
        if (e is File && p.basename(e.path).startsWith('dl_')) {
          temp += await e.length();
        }
      }
    }
    return StorageUsage(
      videos: usage,
      modelsBytes: await _dirBytes(
        Directory(p.join(support.path, 'whisper_models')),
      ),
      tempBytes: temp,
    );
  }

  @override
  Future<int> clearTemp() async {
    var freed = 0;
    for (final d in await _tempDirs()) {
      freed += await _dirBytes(d);
      if (d.existsSync()) await d.delete(recursive: true);
    }
    final cache = await getTemporaryDirectory();
    if (cache.existsSync()) {
      for (final e in cache.listSync()) {
        if (e is File && p.basename(e.path).startsWith('dl_')) {
          freed += await e.length();
          await e.delete();
        }
      }
    }
    return freed;
  }
}
