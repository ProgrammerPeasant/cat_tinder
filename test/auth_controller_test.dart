import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cat_tinder/features/auth/auth_controller.dart';
import 'package:cat_tinder/core/models/user.dart';
import 'package:cat_tinder/core/load_state.dart';
import 'package:cat_tinder/core/services/local_auth_service.dart';
import 'package:cat_tinder/core/services/analytics_service.dart';
import 'package:cat_tinder/core/models/auth_exception.dart';

class MockLocalAuthService extends Mock implements LocalAuthService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  group('AuthController', () {
    late MockLocalAuthService mockAuthService;
    late MockAnalyticsService mockAnalyticsService;
    late AuthController authController;

    setUp(() {
      mockAuthService = MockLocalAuthService();
      mockAnalyticsService = MockAnalyticsService();
      authController = AuthController(
        mockAuthService,
        analyticsService: mockAnalyticsService,
      );

      when(() => mockAnalyticsService.logEvent(any(), any()))
          .thenAnswer((_) async => {});
      when(() => mockAnalyticsService.setUserId(any()))
          .thenAnswer((_) async => {});
      when(() => mockAnalyticsService.clearUserId())
          .thenAnswer((_) async => {});
    });

    group('register', () {
      test('should set state to loading then success on successful registration',
          () async {
        const testUser = User(
          id: 'test_id',
          email: 'test@example.com',
          displayName: 'Test User',
        );

        when(
          () => mockAuthService.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          ),
        ).thenAnswer((_) async => testUser);

        expect(authController.state, LoadState.initial);
        expect(authController.currentUser, isNull);

        await authController.register(
          email: 'test@example.com',
          password: 'Password123',
          displayName: 'Test User',
        );

        expect(authController.state, LoadState.success);
        expect(authController.currentUser, testUser);
        expect(authController.error, isNull);
        
        // Verify analytics were called
        verify(() => mockAnalyticsService.logEvent(
          AnalyticsEvents.userRegistered,
          any(),
        )).called(1);
      });

      test('should set state to error on registration failure', () async {
        final exception = InvalidEmailException('Invalid email');

        when(
          () => mockAuthService.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          ),
        ).thenThrow(exception);

        await authController.register(
          email: 'invalid',
          password: 'Password123',
          displayName: 'Test User',
        );

        expect(authController.state, LoadState.error);
        expect(authController.error, exception);
        expect(authController.currentUser, isNull);
        
        verify(() => mockAnalyticsService.logEvent(
          AnalyticsEvents.registrationFailed,
          any(),
        )).called(1);
      });
    });

    group('login', () {
      test('should set state to success on successful login', () async {
        const testUser = User(
          id: 'test_id',
          email: 'test@example.com',
          displayName: 'Test User',
        );

        when(
          () => mockAuthService.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => testUser);

        await authController.login(
          email: 'test@example.com',
          password: 'Password123',
        );

        expect(authController.state, LoadState.success);
        expect(authController.currentUser, testUser);
        expect(authController.error, isNull);
        
        verify(() => mockAnalyticsService.logEvent(
          AnalyticsEvents.userLoggedIn,
          any(),
        )).called(1);
      });

      test('should set state to error on login failure', () async {
        final exception = UserNotFoundException('User not found');

        when(
          () => mockAuthService.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(exception);

        await authController.login(
          email: 'nonexistent@example.com',
          password: 'Password123',
        );

        expect(authController.state, LoadState.error);
        expect(authController.error, exception);
        expect(authController.currentUser, isNull);
        
        verify(() => mockAnalyticsService.logEvent(
          AnalyticsEvents.loginFailed,
          any(),
        )).called(1);
      });
    });

    group('isAuthenticated', () {
      test('should return false when currentUser is null', () {
        expect(authController.isAuthenticated, false);
      });

      test('should return true when currentUser is set', () async {
        const testUser = User(
          id: 'test_id',
          email: 'test@example.com',
          displayName: 'Test User',
        );

        when(
          () => mockAuthService.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => testUser);

        await authController.login(
          email: 'test@example.com',
          password: 'Password123',
        );

        expect(authController.isAuthenticated, true);
      });
    });

    group('logout', () {
      test('should clear current user and reset state', () async {
        const testUser = User(
          id: 'test_id',
          email: 'test@example.com',
          displayName: 'Test User',
        );

        when(
          () => mockAuthService.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => testUser);

        when(() => mockAuthService.logout()).thenAnswer((_) async {});

        await authController.login(
          email: 'test@example.com',
          password: 'Password123',
        );

        expect(authController.currentUser, isNotNull);

        await authController.logout();

        expect(authController.currentUser, isNull);
        expect(authController.state, LoadState.initial);
        
        verify(() => mockAnalyticsService.logEvent(
          AnalyticsEvents.userLoggedOut,
          null,
        )).called(1);
      });
    });

    group('clearError', () {
      test('should clear error message', () async {
        final exception = InvalidEmailException('Invalid email');

        when(
          () => mockAuthService.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          ),
        ).thenThrow(exception);

        await authController.register(
          email: 'invalid',
          password: 'Password123',
          displayName: 'Test User',
        );

        expect(authController.error, isNotNull);

        authController.clearError();

        expect(authController.error, isNull);
      });
    });
  });
}
