import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

/// Rough hardware class, used to recommend the speech model.
abstract interface class DeviceCapability {
  /// Physical RAM in MB, or null if unknown.
  Future<int?> ramMb();
}

class DeviceInfoCapability implements DeviceCapability {
  int? _cached;

  @override
  Future<int?> ramMb() async {
    if (_cached != null) return _cached;
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        _cached = (await info.androidInfo).physicalRamSize;
      } else if (Platform.isIOS) {
        _cached = (await info.iosInfo).physicalRamSize;
      }
    } on Object {
      _cached = null;
    }
    return _cached;
  }
}
