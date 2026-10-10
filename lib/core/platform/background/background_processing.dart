import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Keeps a long job alive while the app is in the background and shows its
/// progress in a notification. Always best-effort: failures never break the job.
abstract interface class BackgroundProcessing {
  Future<void> start({required String title, required String text});
  Future<void> update(String text);
  Future<void> stop();
}

class ForegroundTaskBackgroundProcessing implements BackgroundProcessing {
  var _initialised = false;

  void _init() {
    if (_initialised) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'translation_progress',
        channelName: 'Translation progress',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        allowAutoRestart: false,
      ),
    );
    _initialised = true;
  }

  @override
  Future<void> start({required String title, required String text}) async {
    try {
      _init();
      if (await FlutterForegroundTask.checkNotificationPermission() !=
          NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
      if (await FlutterForegroundTask.isRunningService) return;
      await FlutterForegroundTask.startService(
        serviceId: 256,
        serviceTypes: [ForegroundServiceTypes.dataSync],
        notificationTitle: title,
        notificationText: text,
      );
    } on Object {
      // Notification is a nicety; the job itself keeps running.
    }
  }

  @override
  Future<void> update(String text) async {
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.updateService(notificationText: text);
      }
    } on Object {
      // ignore: best effort, see start()
    }
  }

  @override
  Future<void> stop() async {
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }
    } on Object {
      // ignore: best effort, see start()
    }
  }
}
