sealed class Failure {
  const Failure([this.message]);
  final String? message;
}

final class StorageFailure extends Failure {
  const StorageFailure([super.message]);
}

final class ModelMissingFailure extends Failure {
  const ModelMissingFailure(this.modelId, [super.message]);
  final String modelId;
}

final class UnsupportedMediaFailure extends Failure {
  const UnsupportedMediaFailure([super.message]);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message]);
}

final class CancelledFailure extends Failure {
  const CancelledFailure();
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message]);
}

/// Online mode requested without consent or API key.
final class OnlineNotConfiguredFailure extends Failure {
  const OnlineNotConfiguredFailure([super.message]);
}
