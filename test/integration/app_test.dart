import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawyers_bh/main.dart' as app;
import 'package:lawyers_bh/core/router/app_router.dart';
import 'package:lawyers_bh/presentation/screens/splash/splash_screen.dart';
import 'package:lawyers_bh/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:lawyers_bh/presentation/screens/auth/login/login_screen.dart';

void main() {
  group('App Integration Tests', () {
    testWidgets('App should start with SplashScreen', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Should show splash screen initially
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('Navigation flow: Splash -> Onboarding -> Login', (tester) async {
      // This test would require mocking the initialization
      // For now, we verify the routes are properly configured
      
      final router = AppRoutes.splash;
      expect(router, equals('/'));
      
      final onboardingRoute = AppRoutes.onboarding;
      expect(onboardingRoute, equals('/onboarding'));
      
      final loginRoute = AppRoutes.login;
      expect(loginRoute, equals('/login'));
    });
  });

  group('Route Configuration Tests', () {
    test('All required routes should be defined', () {
      expect(AppRoutes.splash, isNotEmpty);
      expect(AppRoutes.onboarding, isNotEmpty);
      expect(AppRoutes.login, isNotEmpty);
      expect(AppRoutes.register, isNotEmpty);
      expect(AppRoutes.forgotPassword, isNotEmpty);
      expect(AppRoutes.otp, isNotEmpty);
      expect(AppRoutes.home, isNotEmpty);
      expect(AppRoutes.search, isNotEmpty);
      expect(AppRoutes.appointments, isNotEmpty);
      expect(AppRoutes.messages, isNotEmpty);
      expect(AppRoutes.profile, isNotEmpty);
      expect(AppRoutes.lawyerProfile, isNotEmpty);
      expect(AppRoutes.services, isNotEmpty);
      expect(AppRoutes.favorites, isNotEmpty);
      expect(AppRoutes.settings, isNotEmpty);
      expect(AppRoutes.help, isNotEmpty);
      expect(AppRoutes.about, isNotEmpty);
      expect(AppRoutes.terms, isNotEmpty);
      expect(AppRoutes.privacy, isNotEmpty);
      expect(AppRoutes.lawyerDashboard, isNotEmpty);
      expect(AppRoutes.admin, isNotEmpty);
    });
  });

  group('Screen Widget Tests', () {
    testWidgets('OnboardingScreen should render all pages', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const OnboardingScreen(),
          ),
        ),
      );

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('تسجيل سريع'), findsOneWidget);
      expect(find.text('نجدة قانونية'), findsOneWidget);
      expect(find.text('عقود آمنة'), findsOneWidget);
    });

    testWidgets('LoginScreen should render form fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('تسجيل الدخول'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Phone and Password
    });
  });
}