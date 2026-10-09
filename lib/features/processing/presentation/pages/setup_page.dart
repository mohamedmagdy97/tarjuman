import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/core/design_system/components/app_button.dart';
import 'package:tarjuman/core/design_system/components/app_segmented.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/features/processing/domain/entities/processing.dart';
import 'package:tarjuman/features/processing/presentation/cubit/setup_cubit.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

class SetupPage extends StatelessWidget {
  const SetupPage({required this.videoId, super.key});
  final String videoId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = sl<SetupCubit>();
      unawaited(cubit.load(videoId));
      return cubit;
    },
    child: _SetupView(videoId: videoId),
  );
}

class _SetupView extends StatelessWidget {
  const _SetupView({required this.videoId});
  final String videoId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return BlocBuilder<SetupCubit, SetupState>(
      builder: (context, s) {
        final cubit = context.read<SetupCubit>();
        final hint = s.engine == EngineKind.online
            ? (s.onlineReady ? l10n.engineOnlineHint : l10n.onlineSetupNeeded)
            : (s.offlineReady ? l10n.modelsReady : l10n.modelsMissing);
        final fixRoute = s.engine == EngineKind.online
            ? '/settings'
            : '/models';

        return Scaffold(
          appBar: AppBar(title: Text(l10n.setupTitle)),
          body: s.loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.screen),
                    children: [
                      Text(
                        s.video?.title ?? '',
                        textDirection: TextDirection.ltr,
                        style: AppTypography.heading,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _label(c.muted, l10n.modeTitle),
                      AppSegmented<ProcessingMode>(
                        options: {
                          ProcessingMode.prepare: l10n.modePrepare,
                          ProcessingMode.live: l10n.modeLive,
                        },
                        value: s.mode,
                        onChanged: cubit.setMode,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Text(
                          s.mode == ProcessingMode.prepare
                              ? l10n.modePrepareHint
                              : l10n.modeLiveHint,
                          style: AppTypography.caption.copyWith(color: c.muted),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _label(c.muted, l10n.engineTitle),
                      AppSegmented<EngineKind>(
                        options: {
                          EngineKind.offline: l10n.engineOffline,
                          EngineKind.online: l10n.engineOnline,
                        },
                        value: s.engine,
                        onChanged: cubit.setEngine,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Icon(
                            s.canStart
                                ? Icons.lock_outline_rounded
                                : Icons.info_outline_rounded,
                            size: 18,
                            color: s.canStart ? c.signal : c.primaryText,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              hint,
                              style: AppTypography.caption.copyWith(
                                color: c.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!s.canStart)
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton(
                            onPressed: () async {
                              await context.push(fixRoute);
                              await cubit.load(videoId);
                            },
                            child: Text(
                              s.engine == EngineKind.online
                                  ? l10n.settings
                                  : l10n.manageModels,
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xxl),
                      AppButton(
                        label: l10n.startTranslation,
                        icon: Icons.play_arrow_rounded,
                        expand: true,
                        onPressed: s.canStart ? () => _start(context, s) : null,
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  void _start(BuildContext context, SetupState s) {
    final kind = s.engine.name;
    if (s.mode == ProcessingMode.prepare) {
      context.pushReplacement('/processing/$videoId?engine=$kind');
    } else {
      context.pushReplacement('/player/$videoId?live=$kind');
    }
  }

  Widget _label(Color color, String text) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Text(
      text,
      style: AppTypography.caption.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
