import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_exception.dart';
import '../models/user.dart';
import 'secure_storage_service.dart';

abstract class AuthService {
  Future<User> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<User> login({
    required String email,
    required String password,
  });

  Future<User?> getCurrentUser();
  Future<void> logout();
  Future<bool> isUserLoggedIn();
}

class LocalAuthService implements AuthService {
  LocalAuthService({
    required SharedPreferences prefs,
    required SecureStorageService secureStorage,
  })  : _prefs = prefs,
        _secureStorage = secureStorage;

  final SharedPreferences _prefs;
  final SecureStorageService _secureStorage;

  static const String _userKey = 'user_data';
  static const String _emailKey = 'user_email';
  static const String _passwordPrefix = 'password_';
  static const String _isLoggedInKey = 'is_logged_in';

  @override
  Future<User> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Validate email
      if (!_isValidEmail(email)) {
        throw InvalidEmailException('Invalid email format');
      }

      // Validate password
      if (!_isStrongPassword(password)) {
        throw WeakPasswordException(
          'Password must be at least 8 characters with uppercase, lowercase, and numbers',
        );
      }

      // Check if user already exists
      final existingEmail = _prefs.getString(_emailKey);
      if (existingEmail != null && existingEmail == email.toLowerCase()) {
        throw UserAlreadyExistsException('User with this email already exists');
      }

      // Create user
      final user = User(
        id: _generateUserId(),
        email: email.toLowerCase(),
        displayName: displayName,
      );

      // Save user data
      await _prefs.setString(_userKey, _encodeUser(user));
      await _prefs.setString(_emailKey, user.email);
      await _secureStorage.savePassword(_passwordPrefix + user.email, password);
      await _prefs.setBool(_isLoggedInKey, true);

      return user;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthUnknownException('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final storedEmail = _prefs.getString(_emailKey);
      if (storedEmail == null || storedEmail != email.toLowerCase()) {
        throw UserNotFoundException('User not found');
      }

      final storedPassword =
          await _secureStorage.getPassword(_passwordPrefix + email.toLowerCase());
      if (storedPassword == null || storedPassword != password) {
        throw InvalidPasswordException('Invalid password');
      }

      final userJson = _prefs.getString(_userKey);
      if (userJson == null) {
        throw UserNotFoundException('User data not found');
      }

      await _prefs.setBool(_isLoggedInKey, true);
      return _decodeUser(userJson);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthUnknownException('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final isLoggedIn = _prefs.getBool(_isLoggedInKey) ?? false;
      if (!isLoggedIn) {
        return null;
      }

      final userJson = _prefs.getString(_userKey);
      if (userJson == null) {
        return null;
      }

      return _decodeUser(userJson);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _prefs.setBool(_isLoggedInKey, false);
    } catch (e) {
      throw AuthStorageException('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Helper methods
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool _isStrongPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    return true;
  }

  String _generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _encodeUser(User user) {
    final json = user.toJson();
    return '${json['id']}|${json['email']}|${json['displayName']}';
  }

  User _decodeUser(String encoded) {
    final parts = encoded.split('|');
    if (parts.length != 3) {
      throw AuthStorageException('Invalid user data format');
    }
    return User(
      id: parts[0],
      email: parts[1],
      displayName: parts[2],
    );
  }
}
