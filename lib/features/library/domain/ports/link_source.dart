import 'package:tarjuman/core/result/result.dart';

/// Something that can be saved to a file: a direct file, a YouTube stream, an
/// HLS playlist. Sources report their own progress (0..1, or null if unknown).
abstract interface class LinkSource {
  String get title;

  /// File extension without the dot (e.g. `mp4`, `ts`).
  String get extension;

  Stream<List<int>> open(void Function(double? fraction) onProgress);
}

/// Turns any pasted link (file, social post, web page) into a [LinkSource].
abstract interface class LinkResolver {
  Future<Result<LinkSource>> resolve(Uri url, {String? referer});
}
