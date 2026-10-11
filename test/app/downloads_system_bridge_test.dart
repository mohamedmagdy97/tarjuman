import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarjuman/app/downloads_system_bridge.dart';
import 'package:tarjuman/core/platform/background/background_processing.dart';
import 'package:tarjuman/core/platform/notifications/app_notifier.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/core/settings/settings_store.dart';
import 'package:tarjuman/features/downloads/presentation/cubit/downloads_cubit.dart';
import 'package:tarjuman/features/library/domain/entities/video.dart';
import 'package:tarjuman/features/library/domain/usecases/export_video_file.dart';
import 'package:tarjuman/features/library/domain/usecases/import_from_url.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

class _Import extends Mock implements ImportFromUrl {}

class _Export extends Mock implements ExportVideoFile {}

class _Settings extends Fake implements SettingsStore {
  @override
  bool readAutoSaveDownloads() => false;
}

class _Background implements BackgroundProcessing {
  final calls = <String>[];
  @override
  Future<void> start({
    required String owner,
    required String title,
    required String text,
  }) async => calls.add('start:$owner');
  @override
  Future<void> update(String text) async => calls.add('update');
  @override
  Future<void> stop({required String owner}) async => calls.add('stop:$owner');
}

class _Notifier implements AppNotifier {
  final shown = <(int, String, String?)>[];
  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async => shown.add((id, title, payload));
  @override
  Stream<String> get taps => const Stream.empty();
  @override
  Future<String?> launchPayload() async => null;
}

void main() {
  testWidgets('service runs while downloads are active and a finished one '
      'is notified with a route to its setup screen', (tester) async {
    final gate = Completer<Result<Video>>();
    final import = _Import();
    when(
      () => import(
        any(),
        referer: any(named: 'referer'),
        onProgress: any(named: 'onProgress'),
        cancel: any(named: 'cancel'),
      ),
    ).thenAnswer((_) => gate.future);
    final cubit = DownloadsCubit(import, _Export(), _Settings());
    final background = _Background();
    final notifier = _Notifier();
    final bridge = DownloadsSystemBridge(cubit, background, notifier);
    final messenger = GlobalKey<ScaffoldMessengerState>();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        scaffoldMessengerKey: messenger,
        home: const Scaffold(),
      ),
    );
    await tester.runAsync(() => bridge.start(GoRouter(routes: []), messenger));

    cubit.add(const [DownloadRequest(url: 'https://a.b/v')]);
    await tester.pump();
    expect(background.calls.first, 'start:downloads');

    gate.complete(
      Result.success(
        Video(id: 'v1', title: 'Clip', path: '/p', createdAt: DateTime(2026)),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(background.calls.last, 'stop:downloads');
    expect(notifier.shown.single.$3, '/setup/v1');
    await tester.runAsync(() async {
      await bridge.dispose();
      await cubit.close();
    });
  });
}
