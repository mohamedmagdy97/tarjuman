import 'dart:typed_data';

import 'package:tarjuman/features/device_videos/domain/entities/device_video.dart';

/// The phone's video gallery (MediaStore / Photos).
abstract interface class DeviceVideoSource {
  Future<DeviceAccess> requestAccess();
  Future<void> openSettings();

  /// Newest first. Empty list = end reached.
  Future<List<DeviceVideo>> page(int index, {int size = 60});
  Future<Uint8List?> thumbnail(String id);

  /// Real file path for a gallery item (needed by FFmpeg), or null.
  Future<String?> resolvePath(String id);
}
