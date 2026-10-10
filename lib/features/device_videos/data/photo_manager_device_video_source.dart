import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';
import 'package:tarjuman/features/device_videos/domain/entities/device_video.dart';
import 'package:tarjuman/features/device_videos/domain/ports/device_video_source.dart';

class PhotoManagerDeviceVideoSource implements DeviceVideoSource {
  final Map<String, AssetEntity> _assets = {};
  AssetPathEntity? _all;

  @override
  Future<DeviceAccess> requestAccess() async {
    final state = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.video,
          mediaLocation: false,
        ),
      ),
    );
    return switch (state) {
      PermissionState.authorized => DeviceAccess.granted,
      PermissionState.limited => DeviceAccess.limited,
      _ => DeviceAccess.denied,
    };
  }

  @override
  Future<void> openSettings() => PhotoManager.openSetting();

  @override
  Future<List<DeviceVideo>> page(int index, {int size = 60}) async {
    _all ??= (await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.video,
      filterOption: FilterOptionGroup(
        orders: [const OrderOption()],
      ),
    )).firstOrNull;
    final items = await _all?.getAssetListPaged(page: index, size: size) ?? [];
    for (final a in items) {
      _assets[a.id] = a;
    }
    return [
      for (final a in items)
        DeviceVideo(
          id: a.id,
          title: a.title ?? 'video',
          duration: Duration(seconds: a.duration),
        ),
    ];
  }

  @override
  Future<Uint8List?> thumbnail(String id) async {
    final a = _assets[id] ?? await AssetEntity.fromId(id);
    return a?.thumbnailDataWithSize(const ThumbnailSize(240, 150));
  }

  @override
  Future<String?> resolvePath(String id) async {
    final a = _assets[id] ?? await AssetEntity.fromId(id);
    return (await a?.originFile)?.path;
  }
}
