sealed class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class InvalidEmailException extends AuthException {
  const InvalidEmailException(super.message);
}

class WeakPasswordException extends AuthException {
  const WeakPasswordException(super.message);
}

class UserAlreadyExistsException extends AuthException {
  const UserAlreadyExistsException(super.message);
}

class UserNotFoundException extends AuthException {
  const UserNotFoundException(super.message);
}

class InvalidPasswordException extends AuthException {
  const InvalidPasswordException(super.message);
}

class AuthStorageException extends AuthException {
  const AuthStorageException(super.message);
}

class AuthUnknownException extends AuthException {
  const AuthUnknownException(super.message);
}
