import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:tarjuman/app/di/injection.dart';
import 'package:tarjuman/core/design_system/tokens/app_spacing.dart';
import 'package:tarjuman/core/design_system/tokens/theme_context.dart';
import 'package:tarjuman/features/browser/presentation/cubit/browser_cubit.dart';
import 'package:tarjuman/features/browser/presentation/widgets/browser_start.dart';
import 'package:tarjuman/features/browser/presentation/widgets/detected_sheet.dart';
import 'package:tarjuman/features/downloads/presentation/cubit/downloads_cubit.dart';
import 'package:tarjuman/features/library/data/links/page_link_resolver.dart';
import 'package:tarjuman/features/library/domain/link_normalizer.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

/// A small in-app browser: open any site, play a video, and the app lists the
/// videos it saw so one or many can be queued for download.
class BrowserPage extends StatelessWidget {
  const BrowserPage({this.initialUrl, super.key});
  final String? initialUrl;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => BrowserCubit()),
      BlocProvider.value(value: sl<DownloadsCubit>()),
    ],
    child: _BrowserView(initialUrl: initialUrl),
  );
}

class _BrowserView extends StatefulWidget {
  const _BrowserView({this.initialUrl});
  final String? initialUrl;

  @override
  State<_BrowserView> createState() => _BrowserViewState();
}

class _BrowserViewState extends State<_BrowserView> {
  final _address = TextEditingController();
  InAppWebViewController? _web;
  String? _start;

  @override
  void initState() {
    super.initState();
    _start = widget.initialUrl;
    if (_start != null) _address.text = _start!;
  }

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  void _open(String raw) {
    final uri = normalizeUrl(raw);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).errInvalidLink)),
      );
      return;
    }
    _address.text = uri.toString();
    if (_web == null) {
      setState(() => _start = uri.toString());
    } else {
      unawaited(_web!.loadUrl(urlRequest: URLRequest(url: WebUri.uri(uri))));
    }
    FocusScope.of(context).unfocus();
  }

  /// Reads `<video>` sources and the page HTML for anything the network
  /// listener could not see (blob players excluded).
  Future<void> _scan() async {
    final web = _web;
    if (web == null || !mounted) return;
    final cubit = context.read<BrowserCubit>();
    final page = Uri.tryParse((await web.getUrl())?.toString() ?? '');
    if (page == null) return;
    try {
      final result = await web.evaluateJavascript(
        source: '''
(function(){var r=[];
document.querySelectorAll('video').forEach(function(v){
  var s=v.currentSrc||v.src; if(s) r.push(s);
  v.querySelectorAll('source').forEach(function(x){ if(x.src) r.push(x.src); });
});
document.querySelectorAll('meta[property^="og:video"]').forEach(function(m){ if(m.content) r.push(m.content); });
return r;})()''',
      );
      if (result is List) {
        for (final u in result) {
          cubit.found(page.resolve(u.toString()).toString());
        }
      }
      final html = await web.getHtml();
      final fromHtml = html == null
          ? null
          : PageLinkResolver.extractVideoUrl(html);
      if (fromHtml != null) cubit.found(page.resolve(fromHtml).toString());
    } on Object {
      // Scanning is best effort; the network listener may still have hits.
    }
    cubit.titleChanged(await web.getTitle());
  }

  Future<void> _showDetected() async {
    await _scan();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final browser = context.read<BrowserCubit>();
    final downloads = context.read<DownloadsCubit>();
    final s = browser.state;
    final choice = await showModalBottomSheet<DetectedChoice>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DetectedSheet(
        detected: s.detected,
        pageTitle: s.pageTitle ?? s.pageUrl ?? '',
      ),
    );
    if (choice == null || !mounted) return;
    final referer = s.pageUrl;
    downloads.add([
      if (choice.page && s.pageUrl != null)
        DownloadRequest(url: s.pageUrl!, title: s.pageTitle),
      for (final u in choice.urls)
        DownloadRequest(url: u, title: s.pageTitle, referer: referer),
    ]);
    final count = choice.urls.length + (choice.page ? 1 : 0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.browserAdded(count)),
        action: SnackBarAction(
          label: l10n.downloadsTitle,
          onPressed: () => unawaited(context.push('/downloads')),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final browser = context.read<BrowserCubit>();
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _address,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.go,
          autocorrect: false,
          textDirection: TextDirection.ltr,
          onSubmitted: _open,
          decoration: InputDecoration(
            hintText: l10n.browserHint,
            border: InputBorder.none,
          ),
        ),
        actions: [
          BlocBuilder<DownloadsCubit, DownloadsState>(
            builder: (context, d) => IconButton(
              tooltip: l10n.downloadsTitle,
              onPressed: () => unawaited(context.push('/downloads')),
              icon: Badge(
                isLabelVisible: d.active > 0,
                label: Text('${d.active}'),
                child: const Icon(Icons.download_done_rounded),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: BlocBuilder<BrowserCubit, BrowserState>(
            buildWhen: (a, b) => a.progress != b.progress,
            builder: (_, s) => s.progress > 0 && s.progress < 1
                ? LinearProgressIndicator(value: s.progress, minHeight: 2)
                : const SizedBox(height: 2),
          ),
        ),
      ),
      body: _start == null
          ? BrowserStart(onOpen: _open)
          : InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(_start!)),
              initialSettings: InAppWebViewSettings(
                useOnLoadResource: true,
                useShouldInterceptRequest: true,
              ),
              onWebViewCreated: (c) => _web = c,
              onLoadStart: (_, url) => browser.navigated('$url'),
              onUpdateVisitedHistory: (_, url, _) {
                if (url != null) _address.text = '$url';
              },
              onProgressChanged: (_, p) => browser.progressChanged(p / 100),
              onLoadStop: (_, _) => unawaited(_scan()),
              onLoadResource: (_, r) => browser.found('${r.url}'),
              shouldInterceptRequest: (_, request) async {
                browser.found('${request.url}');
                return null;
              },
            ),
      bottomNavigationBar: BottomAppBar(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Row(
          children: [
            IconButton(
              onPressed: () => unawaited(_web?.goBack() ?? Future.value()),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            IconButton(
              onPressed: () => unawaited(_web?.goForward() ?? Future.value()),
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
            IconButton(
              onPressed: () => unawaited(_web?.reload() ?? Future.value()),
              icon: const Icon(Icons.refresh_rounded),
            ),
            const Spacer(),
            BlocBuilder<BrowserCubit, BrowserState>(
              builder: (context, s) => FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: c.primary),
                onPressed: _start == null ? null : _showDetected,
                icon: Badge(
                  isLabelVisible: s.detected.isNotEmpty,
                  label: Text('${s.detected.length}'),
                  child: const Icon(Icons.download_rounded),
                ),
                label: Text(l10n.browserDetected),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
