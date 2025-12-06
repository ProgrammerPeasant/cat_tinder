abstract class AppException implements Exception {
  const AppException(this.message, [this.code]);

  final String message;
  final int? code;

  @override
  String toString() => 'AppException(message: $message, code: $code)';
}

class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

class ParsingException extends AppException {
  const ParsingException(super.message);
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}
