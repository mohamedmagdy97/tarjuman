import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/core/design_system/components/app_button.dart';
import 'package:tarjuman/core/design_system/components/app_chip.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/features/processing/domain/entities/online_provider.dart';
import 'package:tarjuman/features/settings/presentation/cubit/app_settings_cubit.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Pick the speech + translation providers, then fill in each chosen
/// provider's key (and optional model name).
class OnlineProvidersSection extends StatelessWidget {
  const OnlineProvidersSection({required this.state, super.key});
  final AppSettingsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<AppSettingsCubit>();
    final chosen = {state.speechProvider, state.translationProvider};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Heading(l10n.speechProviderTitle),
        _Choices(
          providers: OnlineProvider.speechProviders,
          selected: state.speechProvider,
          onPick: cubit.setSpeechProvider,
        ),
        _Heading(l10n.translationProviderTitle),
        _Choices(
          providers: OnlineProvider.translationProviders,
          selected: state.translationProvider,
          onPick: cubit.setTranslationProvider,
        ),
        for (final p in chosen)
          ProviderCard(
            key: ValueKey(p.id),
            provider: p,
            asSpeech: p == state.speechProvider,
            asTranslation: p == state.translationProvider,
            hasKey: state.hasKey(p),
          ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(
      top: AppSpacing.md,
      bottom: AppSpacing.sm,
    ),
    child: Text(text, style: AppTypography.body),
  );
}

class _Choices extends StatelessWidget {
  const _Choices({
    required this.providers,
    required this.selected,
    required this.onPick,
  });
  final List<OnlineProvider> providers;
  final OnlineProvider selected;
  final ValueChanged<OnlineProvider> onPick;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    children: [
      for (final p in providers)
        AppChip(
          label: p.name,
          selected: p == selected,
          onTap: () => onPick(p),
        ),
    ],
  );
}

class ProviderCard extends StatefulWidget {
  const ProviderCard({
    required this.provider,
    required this.asSpeech,
    required this.asTranslation,
    required this.hasKey,
    super.key,
  });
  final OnlineProvider provider;
  final bool asSpeech;
  final bool asTranslation;
  final bool hasKey;

  @override
  State<ProviderCard> createState() => _ProviderCardState();
}

class _ProviderCardState extends State<ProviderCard> {
  final _key = TextEditingController();
  late final _speechModel = TextEditingController();
  late final _translationModel = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AppSettingsCubit>();
    _speechModel.text = cubit.model(widget.provider, speech: true);
    _translationModel.text = cubit.model(widget.provider, speech: false);
  }

  @override
  void dispose() {
    _key.dispose();
    _speechModel.dispose();
    _translationModel.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final cubit = context.read<AppSettingsCubit>();
    final p = widget.provider;
    if (p.needsKey && _key.text.trim().isNotEmpty) {
      await cubit.saveApiKey(p, _key.text);
      _key.clear();
    }
    if (widget.asSpeech) {
      await cubit.saveModel(p, speech: true, model: _speechModel.text);
    }
    if (widget.asTranslation) {
      await cubit.saveModel(p, speech: false, model: _translationModel.text);
    }
  }

  Widget _field(TextEditingController c, String label, {bool secret = false}) =>
      Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: TextField(
          controller: c,
          obscureText: secret,
          autocorrect: false,
          enableSuggestions: false,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(labelText: label),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final p = widget.provider;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: c.line),
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.name, style: AppTypography.heading),
              Text(
                arabic ? p.noteAr : p.noteEn,
                style: AppTypography.caption.copyWith(color: c.muted),
              ),
              if (p.needsKey)
                _field(
                  _key,
                  l10n.apiKeyOf(p.name),
                  secret: true,
                ),
              if (p.needsKey && widget.hasKey)
                Text(
                  l10n.apiKeySaved,
                  style: AppTypography.caption.copyWith(color: c.muted),
                )
              else if (!p.needsKey)
                Text(
                  l10n.noKeyNeeded,
                  style: AppTypography.caption.copyWith(color: c.muted),
                ),
              if (p.speechModel.isNotEmpty && widget.asSpeech)
                _field(
                  _speechModel,
                  '${l10n.modelOverride} · ${p.speechModel}',
                ),
              if (p.translationModel.isNotEmpty && widget.asTranslation)
                _field(
                  _translationModel,
                  '${l10n.modelOverride} · ${p.translationModel}',
                ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: l10n.save,
                      kind: AppButtonKind.secondary,
                      onPressed: _save,
                    ),
                  ),
                  if (p.needsKey) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: l10n.getApiKey,
                        kind: AppButtonKind.ghost,
                        onPressed: () => unawaited(
                          launchUrl(
                            Uri.parse(p.keyUrl),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
