import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:tarjuman/app/app.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/features/settings/presentation/cubit/app_settings_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  _registerExtraLicenses();
  await configureDependencies();
  await sl<AppSettingsCubit>().init();
  runApp(const TarjumanApp());
}

/// Notices for components that ship as binaries/weights, not Dart packages.
void _registerExtraLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
      ['FFmpeg (via ffmpeg-kit audio build)'],
      'FFmpeg is licensed under the LGPL v3. This app uses the LGPL "audio" '
      'build of ffmpeg-kit as dynamically linked shared libraries. '
      'Source and license texts: https://ffmpeg.org and '
      'https://github.com/arthenica/ffmpeg-kit',
    );
    yield const LicenseEntryWithLineBreaks(
      ['OpenAI Whisper model weights (tiny.en, base.en) and whisper.cpp'],
      'MIT License. Copyright (c) OpenAI (Whisper) and the ggml authors '
      '(whisper.cpp). Models are downloaded by the user on demand.',
    );
    yield const LicenseEntryWithLineBreaks(
      ['IBM Plex Sans Arabic, IBM Plex Mono, Reem Kufi'],
      'SIL Open Font License 1.1. Fonts are bundled with the app.',
    );
  });
}
