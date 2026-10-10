import 'dart:async';

import 'package:flutter/services.dart';

class IncomingMedia {
  const IncomingMedia({required this.path, required this.name});
  final String path;
  final String name;
}

/// Files opened with / shared to the app from other apps.
abstract interface class IncomingMediaSource {
  /// The file the app was launched with, if any.
  Future<IncomingMedia?> initial();

  /// Files delivered while the app is already running.
  Stream<IncomingMedia> get stream;
}

class MethodChannelIncomingMediaSource implements IncomingMediaSource {
  MethodChannelIncomingMediaSource() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onIncoming') {
        final media = _parse(call.arguments);
        if (media != null) _out.add(media);
      }
    });
  }

  static const _channel = MethodChannel('com.megtech.tarjuman/incoming');
  final _out = StreamController<IncomingMedia>.broadcast();

  IncomingMedia? _parse(Object? raw) {
    if (raw is! Map) return null;
    final path = raw['path'];
    final name = raw['name'];
    if (path is! String || name is! String) return null;
    return IncomingMedia(path: path, name: name);
  }

  @override
  Future<IncomingMedia?> initial() async {
    try {
      return _parse(await _channel.invokeMethod<Object?>('getInitial'));
    } on MissingPluginException {
      return null; // non-Android platforms / tests
    }
  }

  @override
  Stream<IncomingMedia> get stream => _out.stream;
}
