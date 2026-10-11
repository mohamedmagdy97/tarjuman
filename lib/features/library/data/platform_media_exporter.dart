import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tarjuman/features/library/domain/ports/media_exporter.dart';

class PlatformMediaExporter implements MediaExporter {
  static const _channel = MethodChannel('com.megtech.tarjuman/export');

  static const _mimes = {
    'mp4': 'video/mp4',
    'm4v': 'video/mp4',
    'webm': 'video/webm',
    'mkv': 'video/x-matroska',
    'mov': 'video/quicktime',
    'avi': 'video/x-msvideo',
    'flv': 'video/x-flv',
    '3gp': 'video/3gpp',
    'ts': 'video/mp2t',
    'mp3': 'audio/mpeg',
    'm4a': 'audio/mp4',
    'aac': 'audio/aac',
    'ogg': 'audio/ogg',
    'wav': 'audio/wav',
  };

  String _mime(String name) =>
      _mimes[name.split('.').last.toLowerCase()] ?? 'video/mp4';

  @override
  Future<bool> saveToDevice({
    required String path,
    required String name,
  }) async {
    try {
      return await _channel.invokeMethod<bool>('save', {
            'path': path,
            'name': name,
            'mime': _mime(name),
          }) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<void> shareFile({required String path, required String name}) =>
      SharePlus.instance.share(
        ShareParams(
          files: [XFile(path, name: name, mimeType: _mime(name))],
        ),
      );
}
