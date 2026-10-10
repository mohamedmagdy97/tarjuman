import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarjuman/features/browser/domain/media_url_filter.dart';

class DetectedVideo extends Equatable {
  const DetectedVideo({required this.url, required this.label});
  final String url;
  final String label;

  @override
  List<Object?> get props => [url, label];
}

class BrowserState extends Equatable {
  const BrowserState({
    this.pageUrl,
    this.pageTitle,
    this.progress = 0,
    this.detected = const [],
  });

  final String? pageUrl;
  final String? pageTitle;

  /// Page load progress 0..1.
  final double progress;
  final List<DetectedVideo> detected;

  BrowserState copyWith({
    String? pageUrl,
    String? pageTitle,
    double? progress,
    List<DetectedVideo>? detected,
    bool clearDetected = false,
  }) => BrowserState(
    pageUrl: pageUrl ?? this.pageUrl,
    pageTitle: pageTitle ?? this.pageTitle,
    progress: progress ?? this.progress,
    detected: clearDetected ? const [] : detected ?? this.detected,
  );

  @override
  List<Object?> get props => [pageUrl, pageTitle, progress, detected];
}

/// Collects video URLs the page loads or declares while the user browses.
class BrowserCubit extends Cubit<BrowserState> {
  BrowserCubit() : super(const BrowserState());

  void navigated(String url) =>
      emit(state.copyWith(pageUrl: url, clearDetected: true));

  void titleChanged(String? title) {
    if (title != null && title.isNotEmpty) {
      emit(state.copyWith(pageTitle: title));
    }
  }

  void progressChanged(double value) => emit(state.copyWith(progress: value));

  /// Network resource or scanned URL; ignored unless it looks like media.
  void found(String url) {
    if (!MediaUrlFilter.looksLikeVideo(url)) return;
    final key = MediaUrlFilter.dedupeKey(url);
    if (state.detected.any((d) => MediaUrlFilter.dedupeKey(d.url) == key)) {
      return;
    }
    final uri = Uri.parse(url);
    final name = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : uri.host;
    emit(
      state.copyWith(
        detected: [
          ...state.detected,
          DetectedVideo(url: url, label: '${uri.host} · $name'),
        ],
      ),
    );
  }
}
