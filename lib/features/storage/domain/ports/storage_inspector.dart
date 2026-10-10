import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/storage/domain/entities/storage_usage.dart';

abstract interface class StorageInspector {
  Future<StorageUsage> measure(List<Video> videos);

  /// Deletes temp work/incoming/download files. Returns freed bytes.
  Future<int> clearTemp();
}
