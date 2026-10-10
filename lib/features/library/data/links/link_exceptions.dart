/// A site answered a media request with a non-success status.
class HttpStatusException implements Exception {
  const HttpStatusException(this.status, this.url);
  final int status;
  final Uri url;

  @override
  String toString() => 'HTTP $status';
}
