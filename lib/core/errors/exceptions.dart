class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class StorageException implements Exception {
  final String message;

  const StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}

class ValidationException implements Exception {
  final String message;

  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

class BiometricException implements Exception {
  final String message;

  const BiometricException(this.message);

  @override
  String toString() => 'BiometricException: $message';
}
