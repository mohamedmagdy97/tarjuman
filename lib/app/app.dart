import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/app/router.dart';
import 'package:tarjuman/core/design_system/tokens/app_theme.dart';
import 'package:tarjuman/features/settings/presentation/cubit/app_settings_cubit.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

class TarjumanApp extends StatelessWidget {
  const TarjumanApp({super.key});

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
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
