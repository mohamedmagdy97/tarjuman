import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// One-off notifications (e.g. "download finished"). `payload` is an app
/// route opened when the user taps the notification.
abstract interface class AppNotifier {
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  });

  /// Payloads of notifications tapped while the app runs or that launched it.
  Stream<String> get taps;

  /// The payload of the notification that cold-started the app, if any.
  Future<String?> launchPayload();
}

class LocalAppNotifier implements AppNotifier {
  final _plugin = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<String>.broadcast();
  Future<void>? _ready;

  Future<void> _init() => _ready ??= _plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveNotificationResponse: (r) {
      final p = r.payload;
      if (p != null && p.isNotEmpty) _taps.add(p);
    },
  );

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _init();
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        payload: payload,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'downloads_done',
            'Downloads',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } on Object {
      // A missing notification must never break a finished download.
    }
  }

  @override
  Stream<String> get taps => _taps.stream;

  @override
  Future<String?> launchPayload() async {
    try {
      await _init();
      final d = await _plugin.getNotificationAppLaunchDetails();
      return d?.didNotificationLaunchApp ?? false
          ? d?.notificationResponse?.payload
          : null;
    } on Object {
      return null;
    }
  }
}
