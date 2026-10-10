import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/core/design_system/components/app_button.dart';
import 'package:tarjuman/core/design_system/components/app_progress_bar.dart';
import 'package:tarjuman/core/design_system/tokens/app_radius.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<OnboardingCubit>(),
    child: const OnboardingView(),
  );
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _controller = PageController();
  var _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<OnboardingCubit>().finish();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final pages = [
      (Icons.subtitles_rounded, l10n.onb1Title, l10n.onb1Body),
      (Icons.auto_awesome_rounded, l10n.onb2Title, l10n.onb2Body),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: _finish,
                child: Text(l10n.skip),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  for (final p in pages)
                    _Slide(icon: p.$1, title: p.$2, body: p.$3),
                  const _ModelsSlide(),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 3; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(4),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page ? c.primary : c.line,
                      borderRadius: AppRadius.pill,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: AppButton(
                label: _page < 2 ? l10n.next : l10n.start,
                expand: true,
                onPressed: _page < 2
                    ? () => unawaited(
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                        ),
                      )
                    : _finish,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: c.raised,
              borderRadius: BorderRadius.circular(32),
            ),
            child: SizedBox.square(
              dimension: 110,
              child: Icon(icon, size: 52, color: c.primaryText),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.display.copyWith(fontSize: 28),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: c.muted),
          ),
        ],
      ),
    );
  }
}

class _ModelsSlide extends StatelessWidget {
  const _ModelsSlide();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, s) {
        final cubit = context.read<OnboardingCubit>();
        final working = s.status == SetupStatus.downloading;
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: c.raised,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: SizedBox.square(
                  dimension: 110,
                  child: Icon(
                    s.status == SetupStatus.done
                        ? Icons.check_circle_rounded
                        : Icons.download_for_offline_rounded,
                    size: 52,
                    color: s.status == SetupStatus.done
                        ? c.signal
                        : c.primaryText,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                l10n.onb3Title,
                textAlign: TextAlign.center,
                style: AppTypography.display.copyWith(fontSize: 28),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                switch (s.status) {
                  SetupStatus.done => l10n.onbModelsDone,
                  SetupStatus.failed => l10n.modelsDownloadFailed,
                  SetupStatus.downloading => l10n.onbDownloading(
                    s.step,
                    s.totalSteps,
                  ),
                  SetupStatus.idle => l10n.onb3Body,
                },
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: s.status == SetupStatus.failed ? c.error : c.muted,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (working) AppProgressBar(value: s.fraction),
              if (s.status == SetupStatus.idle ||
                  s.status == SetupStatus.failed)
                AppButton(
                  label: l10n.onbDownloadNow,
                  icon: Icons.download_rounded,
                  kind: AppButtonKind.secondary,
                  onPressed: () => unawaited(cubit.downloadStarterModels()),
                ),
            ],
          ),
        );
      },
    );
  }
}
