import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lawyers_bh_client/models/user.dart';
import 'package:lawyers_bh_client/providers/app_state.dart';
import 'package:lawyers_bh_client/screens/client_shell.dart';
import 'package:lawyers_bh_client/screens/login_otp_screen.dart';
import 'package:lawyers_bh_client/screens/root_shell.dart';
import 'package:lawyers_bh_client/screens/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Keep fonts offline so widget tests never reach the network.
  GoogleFonts.config.allowRuntimeFetching = false;

  group('auth state', () {
    test('a first run with no stored token is reported as firstRun', () async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState();
      expect(await state.bootstrap(), BootstrapResult.firstRun);
      expect(state.isLoggedIn, isFalse);
      expect(state.isGuest, isFalse);
    });

    test('an unverifiable stored token becomes sessionExpired and is cleared', () async {
      SharedPreferences.setMockInitialValues({'auth_token': 'expired-token'});
      final state = AppState();
      // There is no backend in the test, so /auth/me cannot validate the token.
      final result = await state.bootstrap();
      expect(result, BootstrapResult.sessionExpired);
      expect(state.isLoggedIn, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), isNull);
    });
  });

  group('guest mode', () {
    test('continueAsGuest marks guest without a token or user', () async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState();
      await state.continueAsGuest();
      expect(state.isGuest, isTrue);
      expect(state.isLoggedIn, isFalse);
      expect(state.currentUser, isNull);
      expect(state.isProfessional, isFalse);
    });

    test('a guest is never granted permissions', () async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState();
      await state.continueAsGuest();
      expect(state.can('leads.view'), isFalse);
      expect(state.can('cases.view'), isFalse);
    });

    test('logout clears guest state', () async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState();
      await state.continueAsGuest();
      await state.logout();
      expect(state.isGuest, isFalse);
      expect(state.isLoggedIn, isFalse);
    });

    test('a remembered guest choice is restored on the next launch', () async {
      SharedPreferences.setMockInitialValues({'guest_mode': true});
      final state = AppState();
      expect(await state.bootstrap(), BootstrapResult.guest);
      expect(state.isGuest, isTrue);
      expect(state.isLoggedIn, isFalse);
    });

    test('a lawyer identity is still recognised as professional', () {
      final state = AppState();
      state.currentUser = AppUser(id: 1, phone: '+97339000001', role: 'lawyer');
      expect(state.isProfessional, isTrue);
      state.currentUser = AppUser(id: 2, phone: '+97339000002', role: 'client');
      expect(state.isProfessional, isFalse);
    });
  });

  group('splash routing', () {
    // The splash hand-off is a pure decision, tested directly so no screen
    // has to hit the network.
    test('an authenticated session goes to the role-based root shell', () {
      expect(splashDestination(BootstrapResult.authenticated), isA<RootShell>());
    });

    test('a returning guest goes to the guest client shell', () {
      final destination = splashDestination(BootstrapResult.guest);
      expect(destination, isA<ClientShell>());
      expect((destination as ClientShell).guest, isTrue);
    });

    test('an expired session goes to login with a notice', () {
      final destination = splashDestination(BootstrapResult.sessionExpired);
      expect(destination, isA<LoginOtpScreen>());
      expect((destination as LoginOtpScreen).notice, isNotNull);
    });

    test('a first run goes to login with no notice', () {
      final destination = splashDestination(BootstrapResult.firstRun);
      expect(destination, isA<LoginOtpScreen>());
      expect((destination as LoginOtpScreen).notice, isNull);
    });
  });

  group('login screen', () {
    testWidgets('offers a clearly visible guest entry', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: const MaterialApp(home: LoginOtpScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('الدخول كزائر'), findsOneWidget);
      expect(find.text('إرسال رمز التحقق'), findsOneWidget);
    });

    testWidgets('shows the session-expired notice when handed one', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: const MaterialApp(
            home: LoginOtpScreen(notice: 'انتهت صلاحية الجلسة، الرجاء تسجيل الدخول من جديد.'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('انتهت صلاحية الجلسة، الرجاء تسجيل الدخول من جديد.'), findsOneWidget);
    });
  });

  group('guest tab layout', () {
    test('a signed-in client keeps the identity mapping', () {
      for (var d = 0; d < 5; d++) {
        expect(tabIndexFor(d, guest: false), d);
      }
    });

    test('a guest folds the public destinations onto a 3-tab shell', () {
      // Home, directory and profile survive; the two private destinations are gone.
      expect(tabIndexFor(0, guest: true), 0);
      expect(tabIndexFor(1, guest: true), 1);
      expect(tabIndexFor(4, guest: true), 2);
      // Private destinations never resolve to a private child for a guest.
      expect(tabIndexFor(2, guest: true), 0);
      expect(tabIndexFor(3, guest: true), 0);
    });
  });

  group('canonical API usage', () {
    final dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();

    test('no legacy /api/*.php calls exist anywhere in the app', () {
      final offenders = <String>[];
      for (final file in dartFiles) {
        if (file.readAsStringSync().contains('.php')) offenders.add(file.path);
      }
      expect(offenders, isEmpty, reason: 'the app must only speak to the canonical API');
    });

    test('every API path is under /api/v1', () {
      final pattern = RegExp(r"""['"]/api/[^'"]*""");
      for (final file in dartFiles) {
        for (final match in pattern.allMatches(file.readAsStringSync())) {
          expect(match.group(0), startsWith("'/api/v1"),
              reason: 'unexpected endpoint in ${file.path}: ${match.group(0)}');
        }
      }
    });
  });
}
