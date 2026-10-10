import 'package:screen_brightness/screen_brightness.dart';

/// Per-app screen brightness (does not change the system setting).
abstract interface class BrightnessControl {
  Future<double> current();
  Future<void> set(double value);
  Future<void> reset();
}

class ScreenBrightnessControl implements BrightnessControl {
  @override
  Future<double> current() async {
    try {
      return await ScreenBrightness.instance.application;
    } on Object {
      return .5;
    }
  }

  @override
  Future<void> set(double value) async {
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(
        value.clamp(0.02, 1),
      );
    } on Object {
      // Brightness is a nicety; never break playback because of it.
    }
  }

  @override
  Future<void> reset() async {
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } on Object {
      // ignore: see set()
    }
  }
}
