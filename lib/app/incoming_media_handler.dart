import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tarjuman/core/error/failure_message.dart';
import 'package:tarjuman/core/platform/share/incoming_media.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/domain/link_normalizer.dart';
import 'package:tarjuman/features/library/domain/usecases/import_shared_media.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

/// Turns "Open with / Share to Tarjuman" into a library entry and opens its
/// translate screen.
class IncomingMediaHandler {
  IncomingMediaHandler(this._source, this._import);

  final IncomingMediaSource _source;
  final ImportSharedMedia _import;
  StreamSubscription<IncomingMedia>? _sub;

  Future<void> start(
    GoRouter router,
    GlobalKey<ScaffoldMessengerState> messenger,
  ) async {
    Future<void> handle(IncomingMedia m) async {
      final link = m.link;
      if (link != null) {
        final uri = normalizeUrl(link);
        final ctx = messenger.currentContext;
        if (uri != null) {
          unawaited(
            router.push('/browser?url=${Uri.encodeComponent(uri.toString())}'),
          );
        } else if (ctx != null && ctx.mounted) {
          messenger.currentState?.showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(ctx).errInvalidLink)),
          );
        }
        return;
      }
      final res = await _import(path: m.path, name: m.name);
      switch (res) {
        case Success(:final value):
          unawaited(router.push('/setup/${value.id}'));
        case Err(:final failure):
          final ctx = messenger.currentContext;
          if (ctx != null && ctx.mounted) {
            messenger.currentState?.showSnackBar(
              SnackBar(
                content: Text(
                  failureMessage(failure, AppLocalizations.of(ctx)),
                ),
              ),
            );
          }
      }
    }

    _sub ??= _source.stream.listen((m) => unawaited(handle(m)));
    final initial = await _source.initial();
    if (initial != null) await handle(initial);
  }

  Future<void> dispose() async => _sub?.cancel();
}
