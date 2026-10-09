import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tarjuman/core/design_system/components/app_button.dart';
import 'package:tarjuman/core/design_system/components/app_segmented.dart';
import 'package:tarjuman/core/design_system/components/switch_tile.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/features/settings/presentation/cubit/app_settings_cubit.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _key = TextEditingController();

  @override
  void dispose() {
    _key.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, s) {
        final cubit = context.read<AppSettingsCubit>();
        Widget label(String t) => Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.xl,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            t,
            style: AppTypography.caption.copyWith(
              color: c.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
        return Scaffold(
          appBar: AppBar(title: Text(l10n.settingsTitle)),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
              ),
              children: [
                label(l10n.themeTitle),
                AppSegmented<ThemeMode>(
                  options: {
                    ThemeMode.system: l10n.themeSystem,
                    ThemeMode.dark: l10n.themeDark,
                    ThemeMode.light: l10n.themeLight,
                  },
                  value: s.themeMode,
                  onChanged: cubit.setTheme,
                ),
                label(l10n.onlineSection),
                SwitchTile(
                  title: l10n.onlineConsentTitle,
                  subtitle: l10n.onlineConsentBody,
                  value: s.onlineConsent,
                  onChanged: (v) => cubit.setConsent(value: v),
                ),
                if (s.onlineConsent) ...[
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _key,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: l10n.apiKeyLabel,
                      helperText: s.hasApiKey ? l10n.apiKeySaved : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: l10n.save,
                    kind: AppButtonKind.secondary,
                    onPressed: () async {
                      await cubit.saveApiKey(_key.text);
                      _key.clear();
                    },
                  ),
                ],
                label(l10n.aboutSection),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.description_outlined),
                  title: Text(l10n.licenses),
                  onTap: () => unawaited(_showLicenses(context)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showLicenses(BuildContext context) async {
    final info = await PackageInfo.fromPlatform();
    if (!context.mounted) return;
    showLicensePage(
      context: context,
      applicationName: AppLocalizations.of(context).appName,
      applicationVersion: info.version,
    );
  }
}
