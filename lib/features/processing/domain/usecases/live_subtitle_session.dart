import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:tarjuman/core/cancel/cancel_token.dart';
import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_cue.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_timeline.dart';
import 'package:tarjuman/features/processing/domain/ports/engine_provider.dart';
import 'package:tarjuman/features/processing/domain/usecases/process_range.dart';

class LiveUpdate extends Equatable {
  const LiveUpdate({required this.timeline, required this.busy, this.failure});
  final SubtitleTimeline timeline;
  final bool busy;
  final Failure? failure;

  @override
  List<Object?> get props => [timeline.cues.length, busy, failure?.runtimeType];
}

/// Live mode: keeps the window under the playhead (and the next one) translated.
/// Timing is the media position, so seeking just re-targets the worker.
/// Results are not persisted (windows may leave gaps); use Prepare mode to save.
class LiveSubtitleSession {
  LiveSubtitleSession(this._processRange);

  final ProcessRange _processRange;
  static const window = Duration(seconds: 30);

  final _out = StreamController<LiveUpdate>.broadcast();
  final _done = <int>{};
  final _cancel = CancelToken();
  var _timeline = const SubtitleTimeline.empty();
  var _position = Duration.zero;
  var _running = false;
  var _stopped = false;
  late String _mediaPath;
  late EngineSet _engines;
  late Duration _total;

  Stream<LiveUpdate> get updates => _out.stream;

  void start({
    required String mediaPath,
    required EngineSet engines,
    required Duration total,
    Duration position = Duration.zero,
  }) {
    _mediaPath = mediaPath;
    _engines = engines;
    _total = total;
    onPosition(position);
  }

  /// Call on every playback position update; cheap when nothing is needed.
  void onPosition(Duration position) {
    _position = position;
    if (!_running && !_stopped) unawaited(_work());
  }

  int? _nextNeeded() {
    final current = _position.inMilliseconds ~/ window.inMilliseconds;
    for (final i in [current, current + 1]) {
      final startsAt = Duration(milliseconds: i * window.inMilliseconds);
      if (startsAt < _total && !_done.contains(i)) return i;
    }
    return null;
  }

  Future<void> _work() async {
    _running = true;
    try {
      int? next;
      while (!_stopped && (next = _nextNeeded()) != null) {
        final i = next!;
        final start = Duration(milliseconds: i * window.inMilliseconds);
        final length = _total - start < window ? _total - start : window;
        _out.add(LiveUpdate(timeline: _timeline, busy: true));

        final res = await _processRange(
          mediaPath: _mediaPath,
          engines: _engines,
          start: start,
          length: length,
          cancel: _cancel,
        );
        if (_stopped) break;
        switch (res) {
          case Err(:final failure):
            _out.add(
              LiveUpdate(timeline: _timeline, busy: false, failure: failure),
            );
            return;
          case Success(:final value):
            _done.add(i);
            _timeline = _merge(_timeline, start, start + length, value);
            _out.add(LiveUpdate(timeline: _timeline, busy: false));
        }
      }
    } finally {
      _running = false;
    }
  }

  SubtitleTimeline _merge(
    SubtitleTimeline current,
    Duration from,
    Duration to,
    List<SubtitleCue> fresh,
  ) => SubtitleTimeline([
    ...current.cues.where((c) => c.start < from || c.start >= to),
    ...fresh,
  ]);

  Future<void> stop() async {
    _stopped = true;
    _cancel.cancel();
    await _engines.dispose();
    await _out.close();
  }
}
