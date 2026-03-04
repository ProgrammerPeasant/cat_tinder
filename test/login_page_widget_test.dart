import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:cat_tinder/features/auth/login_page.dart';
import 'package:cat_tinder/features/auth/auth_controller.dart';
import 'package:cat_tinder/core/models/auth_exception.dart';
import 'package:cat_tinder/core/services/local_auth_service.dart';
import 'package:cat_tinder/core/services/analytics_service.dart';

class MockAuthService extends Mock implements LocalAuthService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  group('LoginPage Widget Tests', () {
    late MockAuthService mockAuthService;
    late MockAnalyticsService mockAnalyticsService;

    setUp(() {
      mockAuthService = MockAuthService();
      mockAnalyticsService = MockAnalyticsService();
      registerFallbackValue('');

      when(() => mockAnalyticsService.logEvent(any(), any()))
          .thenAnswer((_) async => {});
      when(() => mockAnalyticsService.setUserId(any()))
          .thenAnswer((_) async => {});
      when(() => mockAnalyticsService.clearUserId())
          .thenAnswer((_) async => {});
    });

    testWidgets('should display email and password fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthController(
              mockAuthService,
              analyticsService: mockAnalyticsService,
            ),
            child: const LoginPage(),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('should show validation error for invalid email', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthController(
              mockAuthService,
              analyticsService: mockAnalyticsService,
            ),
            child: const LoginPage(),
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField).first,
        'invalid_email',
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Некорректный формат email'), findsOneWidget);
    });

    testWidgets('should show validation error for empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthController(
              mockAuthService,
              analyticsService: mockAnalyticsService,
            ),
            child: const LoginPage(),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Email не может быть пуст'), findsOneWidget);
    });

    testWidgets('should show error message on login failure', (WidgetTester tester) async {
      when(
        () => mockAuthService.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(UserNotFoundException('User not found'));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthController(
              mockAuthService,
              analyticsService: mockAnalyticsService,
            ),
            child: const LoginPage(),
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'Password123',
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle();
      expect(find.text('User not found'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthController(
              mockAuthService,
              analyticsService: mockAnalyticsService,
            ),
            child: const LoginPage(),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off).first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should navigate to register page', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthController(
              mockAuthService,
              analyticsService: mockAnalyticsService,
            ),
            child: const LoginPage(),
          ),
        ),
      );

      expect(find.text('Зарегистрироваться'), findsOneWidget);

      await tester.tap(find.text('Зарегистрироваться'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsNothing);
    });
  });
}
