import 'package:tarjuman/core/error/failure.dart';
import 'package:tarjuman/l10n/gen/app_localizations.dart';

/// Single place that turns a Failure into an actionable, localized message.
String failureMessage(Failure failure, AppLocalizations l10n) =>
    switch (failure) {
      UnsupportedMediaFailure() => l10n.errUnsupported,
      InvalidSubtitleFailure() => l10n.errSubtitle,
      UnsupportedLanguageFailure() => l10n.errLanguageUnsupported,
      StorageFailure() => l10n.errStorage,
      NetworkFailure() => l10n.errNetwork,
      ModelMissingFailure() => l10n.errModel,
      RateLimitedFailure() => l10n.errRateLimited,
      OnlineNotConfiguredFailure() => l10n.errOnlineNotConfigured,
      CancelledFailure() || UnknownFailure() => l10n.errUnknown,
    };
