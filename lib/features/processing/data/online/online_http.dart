import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tarjuman/core/error/failure.dart';

/// Maps a non-success HTTP status from any provider to a user-actionable
/// failure: bad key, quota/rate limit, or a generic network error.
Failure failureForStatus(int status) => switch (status) {
  401 || 403 => const OnlineNotConfiguredFailure('Invalid API key'),
  402 || 429 || 456 => RateLimitedFailure('HTTP $status'),
  _ => NetworkFailure('HTTP $status'),
};

/// Runs a provider call and converts transport exceptions to failures.
Future<T> guardOnline<T>(
  Future<T> Function() body,
  T Function(Failure failure) onFailure,
) async {
  try {
    return await body();
  } on SocketException {
    return onFailure(const NetworkFailure());
  } on http.ClientException catch (e) {
    return onFailure(NetworkFailure(e.message));
  } on FormatException {
    return onFailure(const UnknownFailure('Bad provider response'));
  }
}
