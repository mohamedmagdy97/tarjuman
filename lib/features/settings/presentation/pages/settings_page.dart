import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tarjuman/core/config/app_config.dart';
import 'package:tarjuman/core/design_system/components/app_segmented.dart';
import 'package:tarjuman/core/design_system/components/switch_tile.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/features/settings/presentation/cubit/app_settings_cubit.dart';
import 'package:tarjuman/features/settings/presentation/widgets/online_providers_section.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
                if (s.onlineConsent) OnlineProvidersSection(state: s),
                label(l10n.glossaryTitle),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.translate_rounded),
                  title: Text(l10n.glossaryTitle),
                  onTap: () => unawaited(context.push('/glossary')),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.storage_rounded),
                  title: Text(l10n.storageEntry),
                  onTap: () => unawaited(context.push('/storage')),
                ),
                label(l10n.aboutSection),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(l10n.privacyPolicy),
                  onTap: () => unawaited(
                    launchUrl(
                      Uri.parse(AppConfig.privacyPolicyUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ),
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
