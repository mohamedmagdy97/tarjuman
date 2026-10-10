/// Turns whatever the user pasted ("watch this https://x.com/v", "www.x.com/v",
/// "x.com/v") into an http(s) [Uri], or null when it is not a web address.
Uri? normalizeUrl(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  final embedded = RegExp(
    r'https?://[^\s<>"]+',
    caseSensitive: false,
  ).firstMatch(text)?.group(0);
  var candidate = embedded ?? text;
  if (embedded == null) {
    if (candidate.contains(RegExp(r'\s')) || !candidate.contains('.')) {
      return null;
    }
    candidate = 'https://$candidate';
  }
  final uri = Uri.tryParse(candidate);
  if (uri == null || !uri.hasAuthority || !uri.host.contains('.')) return null;
  return uri;
}
