import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/core/result/result.dart';
import 'package:tarjuman/features/library/data/links/page_link_resolver.dart';
import 'package:tarjuman/features/library/data/links/youtube_link_resolver.dart';
import 'package:tarjuman/features/library/domain/ports/link_source.dart';

class CompositeLinkResolver implements LinkResolver {
  CompositeLinkResolver({YoutubeLinkResolver? youtube, PageLinkResolver? page})
    : _youtube = youtube ?? YoutubeLinkResolver(),
      _page = page ?? PageLinkResolver();
  final YoutubeLinkResolver _youtube;
  final PageLinkResolver _page;

  @override
  Future<Result<LinkSource>> resolve(Uri url, {String? referer}) async {
    if (YoutubeLinkResolver.handles(url)) {
      try {
        return Result.success(await _youtube.resolve(url));
      } on Object catch (e) {
        return Result.failure(
          NoVideoFoundFailure('YouTube: ${e.toString().split('\n').first}'),
        );
      }
    }
    return _page.resolve(url, referer: referer);
  }
}
