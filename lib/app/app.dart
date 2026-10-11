import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/app/downloads_system_bridge.dart';
import 'package:tarjuman/app/incoming_media_handler.dart';
import 'package:tarjuman/core/design_system/tokens/app_theme.dart';
import 'package:tarjuman/features/settings/presentation/cubit/app_settings_cubit.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

class TarjumanApp extends StatefulWidget {
  const TarjumanApp({super.key});

  @override
  State<TarjumanApp> createState() => _TarjumanAppState();
}

class _TarjumanAppState extends State<TarjumanApp> {
  @override
  void initState() {
    super.initState();
    // After the first frame so the router and messenger are mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        sl<IncomingMediaHandler>().start(
          sl<GoRouter>(),
          sl<GlobalKey<ScaffoldMessengerState>>(),
        ),
      );
      unawaited(
        sl<DownloadsSystemBridge>().start(
          sl<GoRouter>(),
          sl<GlobalKey<ScaffoldMessengerState>>(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AppSettingsCubit>(),
      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        buildWhen: (a, b) => a.themeMode != b.themeMode,
        builder: (context, s) => MaterialApp.router(
          onGenerateTitle: (c) => AppLocalizations.of(c).appName,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: s.themeMode,
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          scaffoldMessengerKey: sl<GlobalKey<ScaffoldMessengerState>>(),
          routerConfig: sl<GoRouter>(),
        ),
      ),
    );
  }
}
