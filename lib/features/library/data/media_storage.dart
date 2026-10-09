import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Moves picked files from the picker's cache into durable app storage.
class MediaStorage {
  Future<String> persist(String sourcePath, {required String id}) async {
    final root = await getApplicationSupportDirectory();
    final dir = Directory(p.join(root.path, 'videos'));
    await dir.create(recursive: true);
    final target = p.join(dir.path, '$id${p.extension(sourcePath)}');
    final source = File(sourcePath);
    try {
      await source.rename(target);
    } on FileSystemException {
      // Different volume: fall back to copy.
      await source.copy(target);
    }
    return target;
  }

  Future<void> delete(String path) async {
    final f = File(path);
    if (f.existsSync()) await f.delete();
  }
}
