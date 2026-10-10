import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/core/design_system/components/empty_state.dart';
import 'package:tarjuman/core/design_system/tokens/app_radius.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/app_typography.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/features/device_videos/domain/entities/device_video.dart';
import 'package:tarjuman/features/device_videos/presentation/cubit/device_videos_cubit.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

class DeviceVideosPage extends StatelessWidget {
  const DeviceVideosPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = sl<DeviceVideosCubit>();
      unawaited(cubit.start());
      return cubit;
    },
    child: const DeviceVideosView(),
  );
}

class DeviceVideosView extends StatelessWidget {
  const DeviceVideosView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<DeviceVideosCubit, DeviceVideosState>(
      listenWhen: (a, b) => b.openedId != null && a.openedId != b.openedId,
      listener: (context, s) {
        final id = s.openedId!;
        context.read<DeviceVideosCubit>().openedHandled();
        context.pushReplacement('/setup/$id');
      },
      builder: (context, s) {
        final cubit = context.read<DeviceVideosCubit>();
        return Scaffold(
          appBar: AppBar(title: Text(l10n.deviceVideosTitle)),
          body: _body(context, s, cubit, l10n),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    DeviceVideosState s,
    DeviceVideosCubit cubit,
    AppLocalizations l10n,
  ) {
    if (s.access == DeviceAccess.denied) {
      return EmptyState(
        icon: Icons.lock_outline_rounded,
        title: l10n.galleryPermissionTitle,
        body: l10n.galleryPermissionBody,
        actionLabel: l10n.openSettings,
        onAction: () => unawaited(cubit.openSettings()),
      );
    }
    if (s.loading) return const Center(child: CircularProgressIndicator());
    if (s.videos.isEmpty) {
      return EmptyState(
        icon: Icons.video_library_outlined,
        title: l10n.noDeviceVideos,
        body: '',
      );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels > n.metrics.maxScrollExtent - 600) {
          unawaited(cubit.loadMore());
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 16 / 11,
        ),
        itemCount: s.videos.length,
        itemBuilder: (context, i) => _Tile(video: s.videos[i]),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.video});
  final DeviceVideo video;

  String get _duration {
    String two(int n) => n.toString().padLeft(2, '0');
    final d = video.duration;
    final m = two(d.inMinutes.remainder(60));
    final sec = two(d.inSeconds.remainder(60));
    return d.inHours > 0 ? '${d.inHours}:$m:$sec' : '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DeviceVideosCubit>();
    return InkWell(
      borderRadius: AppRadius.smAll,
      onTap: () => unawaited(cubit.pick(video)),
      child: ClipRRect(
        borderRadius: AppRadius.smAll,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: context.colors.raised),
            FutureBuilder(
              future: cubit.thumbnail(video.id),
              builder: (context, snap) => snap.data == null
                  ? const SizedBox.shrink()
                  : Image.memory(snap.data!, fit: BoxFit.cover),
            ),
            PositionedDirectional(
              end: 4,
              bottom: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .62),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      _duration,
                      style: AppTypography.timecode.copyWith(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
