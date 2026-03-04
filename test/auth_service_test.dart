import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cat_tinder/core/models/auth_exception.dart';
import 'package:cat_tinder/core/services/secure_storage_service.dart';
import 'package:cat_tinder/core/services/local_auth_service.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('LocalAuthService', () {
    late MockSharedPreferences mockPrefs;
    late MockSecureStorageService mockSecureStorage;
    late LocalAuthService authService;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      mockSecureStorage = MockSecureStorageService();
      authService = LocalAuthService(
        prefs: mockPrefs,
        secureStorage: mockSecureStorage,
      );

      when(() => mockPrefs.getString(any())).thenReturn(null);
      when(() => mockPrefs.getBool(any())).thenReturn(false);
      when(() => mockPrefs.setString(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockPrefs.setBool(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSecureStorage.savePassword(any(), any()))
          .thenAnswer((_) async => {});
      when(() => mockSecureStorage.getPassword(any()))
          .thenAnswer((_) async => null);
    });

    group('register', () {
      test('should throw InvalidEmailException for invalid email format', () async {
        expect(
          () => authService.register(
            email: 'invalidemail',
            password: 'Password123',
            displayName: 'Test User',
          ),
          throwsA(isA<InvalidEmailException>()),
        );
      });

      test('should throw WeakPasswordException for weak password', () async {
        expect(
          () => authService.register(
            email: 'test@example.com',
            password: 'weak',
            displayName: 'Test User',
          ),
          throwsA(isA<WeakPasswordException>()),
        );
      });

      test('should throw WeakPasswordException if password lacks uppercase',
          () async {
        expect(
          () => authService.register(
            email: 'test@example.com',
            password: 'password123',
            displayName: 'Test User',
          ),
          throwsA(isA<WeakPasswordException>()),
        );
      });

      test('should throw WeakPasswordException if password lacks lowercase',
          () async {
        expect(
          () => authService.register(
            email: 'test@example.com',
            password: 'PASSWORD123',
            displayName: 'Test User',
          ),
          throwsA(isA<WeakPasswordException>()),
        );
      });

      test('should throw WeakPasswordException if password lacks numbers',
          () async {
        expect(
          () => authService.register(
            email: 'test@example.com',
            password: 'PasswordAbc',
            displayName: 'Test User',
          ),
          throwsA(isA<WeakPasswordException>()),
        );
      });

      test('should throw UserAlreadyExistsException if email is already used',
          () async {
        when(() => mockPrefs.getString('user_email'))
            .thenReturn('test@example.com');

        expect(
          () => authService.register(
            email: 'test@example.com',
            password: 'Password123',
            displayName: 'New User',
          ),
          throwsA(isA<UserAlreadyExistsException>()),
        );
      });

      test('should successfully register a new user with valid data', () async {
        final result = await authService.register(
          email: 'newuser@example.com',
          password: 'Password123',
          displayName: 'New User',
        );

        expect(result.email, 'newuser@example.com');
        expect(result.displayName, 'New User');
        expect(result.id, isNotEmpty);

        verify(() => mockPrefs.setString('user_data', any())).called(1);
        verify(() => mockPrefs.setString('user_email', 'newuser@example.com'))
            .called(1);
        verify(() => mockSecureStorage.savePassword(any(), 'Password123'))
            .called(1);
        verify(() => mockPrefs.setBool('is_logged_in', true)).called(1);
      });
    });

    group('login', () {
      test('should throw UserNotFoundException if email does not exist',
          () async {
        when(() => mockPrefs.getString('user_email')).thenReturn(null);

        expect(
          () => authService.login(
            email: 'nonexistent@example.com',
            password: 'Password123',
          ),
          throwsA(isA<UserNotFoundException>()),
        );
      });

      test('should throw InvalidPasswordException for wrong password',
          () async {
        when(() => mockPrefs.getString('user_email'))
            .thenReturn('test@example.com');
        when(() => mockSecureStorage.getPassword(any()))
            .thenAnswer((_) async => 'Password123');

        expect(
          () => authService.login(
            email: 'test@example.com',
            password: 'WrongPassword123',
          ),
          throwsA(isA<InvalidPasswordException>()),
        );
      });

      test('should successfully login with correct credentials', () async {
        const email = 'test@example.com';
        const password = 'Password123';
        const userData = 'user_123|test@example.com|Test User';

        when(() => mockPrefs.getString('user_email')).thenReturn(email);
        when(() => mockSecureStorage.getPassword(any()))
            .thenAnswer((_) async => password);
        when(() => mockPrefs.getString('user_data')).thenReturn(userData);

        final result = await authService.login(
          email: email,
          password: password,
        );

        expect(result.email, email);
        expect(result.displayName, 'Test User');
        verify(() => mockPrefs.setBool('is_logged_in', true)).called(1);
      });
    });

    group('isUserLoggedIn', () {
      test('should return false if user is not logged in', () async {
        when(() => mockPrefs.getBool('is_logged_in')).thenReturn(false);

        final result = await authService.isUserLoggedIn();

        expect(result, false);
      });

      test('should return true if user is logged in', () async {
        when(() => mockPrefs.getBool('is_logged_in')).thenReturn(true);

        final result = await authService.isUserLoggedIn();

        expect(result, true);
      });
    });

    group('logout', () {
      test('should set is_logged_in to false', () async {
        await authService.logout();

        verify(() => mockPrefs.setBool('is_logged_in', false)).called(1);
      });
    });
  });
}
