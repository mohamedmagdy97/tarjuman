import 'package:flutter/material.dart';
import 'package:tarjuman/app/app.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/features/settings/presentation/cubit/app_settings_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await sl<AppSettingsCubit>().init();
  runApp(const TarjumanApp());
}
