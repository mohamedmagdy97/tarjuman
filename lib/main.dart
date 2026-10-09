import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:tarjuman/app/app.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/features/settings/presentation/cubit/app_settings_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await configureDependencies();
  await sl<AppSettingsCubit>().init();
  runApp(const TarjumanApp());
}
