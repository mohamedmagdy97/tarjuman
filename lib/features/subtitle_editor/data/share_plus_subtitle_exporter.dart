import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tarjuman/features/subtitle_editor/domain/ports/subtitle_exporter.dart';

class SharePlusSubtitleExporter implements SubtitleExporter {
  @override
  Future<void> share({
    required String fileName,
    required String content,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsString(content);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: 'application/x-subrip')]),
    );
  }
}
