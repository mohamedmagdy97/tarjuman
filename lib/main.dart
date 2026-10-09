import 'package:flutter/material.dart';
import 'package:tarjuman/app/app.dart';
import 'package:tarjuman/app/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const TarjumanApp());
}
