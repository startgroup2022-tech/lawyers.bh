import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lawyers_bh_client/models/user.dart';
import 'package:lawyers_bh_client/providers/app_state.dart';
import 'package:lawyers_bh_client/screens/client_shell.dart';
import 'package:lawyers_bh_client/screens/login_otp_screen.dart';
import 'package:lawyers_bh_client/screens/lawyer_shell.dart';
import 'package:lawyers_bh_client/screens/root_shell.dart';
import 'package:lawyers_bh_client/screens/splash_screen.dart';
import 'package:lawyers_bh_client/services/api_client.dart';
import 'package:lawyers_bh_client/widgets/promo_banner.dart';
import 'package:lawyers_bh_client/widgets/section_card.dart';

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

    test('an unreachable backend keeps the stored token and reports offline', () async {
      SharedPreferences.setMockInitialValues({'auth_token': 'stored-token'});
      final state = AppState();
      // There is no backend in the test, so /auth/me cannot be reached. That is
      // a transport failure, not a rejection: the token must survive so a retry
      // can still restore the session.
      final result = await state.bootstrap();
      expect(result, BootstrapResult.offline);
      expect(state.isLoggedIn, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), 'stored-token');
    });

    test('a valid stored token restores the authenticated session', () async {
      SharedPreferences.setMockInitialValues({'auth_token': 'good-token'});
      final state = AppState();
      state.identityLoader = () async =>
          AppUser(id: '1', phone: '+97339000001', role: 'client');
      final result = await state.bootstrap();
      expect(result, BootstrapResult.authenticated);
      expect(state.isLoggedIn, isTrue);
      expect(state.isProfessional, isFalse);
    });

    test('a rejected token becomes sessionExpired and is cleared', () async {
      SharedPreferences.setMockInitialValues({'auth_token': 'expired-token'});
      final state = AppState();
      state.identityLoader = () async =>
          throw const ApiException('invalid_or_expired_token', 401);
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
      state.currentUser = AppUser(id: '1', phone: '+97339000001', role: 'lawyer');
      expect(state.isProfessional, isTrue);
      state.currentUser = AppUser(id: '2', phone: '+97339000002', role: 'client');
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

    test('an offline backend stays on the splash so it can be retried', () {
      expect(splashDestination(BootstrapResult.offline), isNull);
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
      expect(find.text('تسجيل الدخول'), findsWidgets);
      expect(find.text('إنشاء حساب'), findsOneWidget);
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

    testWidgets('has no slider, category grid or services strip', (tester) async {
      tester.view.physicalSize = const Size(1200, 3400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: const MaterialApp(home: LoginOtpScreen()),
        ),
      );
      await tester.pump();

      // The sign-in door is a compact form: no home carousel, no category
      // grid, no services strip borrowed from the home screen.
      expect(find.byType(PageView), findsNothing);
      expect(find.byType(PromoBanner), findsNothing);
      expect(find.byType(SectionGrid), findsNothing);
      expect(find.byType(ServicesStrip), findsNothing);
      expect(find.text('الأقسام الرئيسية'), findsNothing);

      // Both doors and the sign-in/sign-up switch stay compact segmented
      // controls, not stacked cards.
      expect(find.text('محامٍ'), findsOneWidget);
      expect(find.text('عميل'), findsOneWidget);
      expect(find.text('تسجيل الدخول'), findsWidgets);
      expect(find.text('إنشاء حساب'), findsOneWidget);
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

  group('account kind and door separation', () {
    http.Response okJson(Map<String, dynamic> body) => http.Response(
          jsonEncode(body),
          200,
          headers: {'content-type': 'application/json'},
        );

    ApiClient failingClient() => ApiClient(
          httpClient: MockClient((_) async => http.Response(
                jsonEncode({'ok': false, 'error': 'server_error'}),
                500,
                headers: {'content-type': 'application/json'},
              )),
        );

    test('a lawyer login marks the account professional and persists the kind',
        () async {
      SharedPreferences.setMockInitialValues({});
      final paths = <String>[];
      final app = AppState(
        apiClient: ApiClient(httpClient: MockClient((req) async {
          paths.add(req.url.path);
          if (req.url.path == '/api/lawyers/login') {
            return okJson({
              'success': true,
              'data': {'id': 'L1', 'phone': '+97339000002', 'token': 'lawyer-token', 'status': 'approved'},
            });
          }
          if (req.url.path == '/api/mobile/lawyer/session') {
            return okJson({
              'ok': true,
              'lawyer': {
                'id': 'L1',
                'nameAr': 'محمد ناجي',
                'phone': '+97339000002',
                'status': 'approved',
                'countryCode': 'BH',
              },
            });
          }
          return http.Response('{}', 404);
        })),
      );

      final (token, user) = await app.lawyerAuth.login(
        licenseNumber: 'BH-12345',
        password: 'password123',
      );
      expect(token, 'lawyer-token');
      expect(user.kind, AccountKind.lawyer);
      expect(user.isProfessional, isTrue, reason: 'the lawyer door is professional');
      expect(paths, contains('/api/mobile/lawyer/session'),
          reason: 'the profile is completed from the lawyer session');

      await app.completeLogin(token, user);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), 'lawyer-token');
      expect(prefs.getString('account_kind'), 'lawyer');
      expect(app.isProfessional, isTrue);
    });

    test('a stored lawyer token is restored through the lawyer endpoint', () async {
      SharedPreferences.setMockInitialValues(
          {'auth_token': 'lawyer-token', 'account_kind': 'lawyer'});
      final paths = <String>[];
      final app = AppState(
        apiClient: ApiClient(httpClient: MockClient((req) async {
          paths.add(req.url.path);
          return okJson({
            'ok': true,
            'lawyer': {'id': 'L1', 'nameAr': 'محمد ناجي', 'phone': '+973', 'status': 'approved'},
          });
        })),
      );

      expect(await app.bootstrap(), BootstrapResult.authenticated);
      expect(paths, contains('/api/mobile/lawyer/session'));
      expect(paths, isNot(contains('/api/mobile/client-auth/session')),
          reason: 'a lawyer token is not a client token');
      expect(app.isProfessional, isTrue);
    });

    test('a stored client token is restored through the client endpoint', () async {
      SharedPreferences.setMockInitialValues(
          {'auth_token': 'client-token', 'account_kind': 'client'});
      final paths = <String>[];
      final app = AppState(
        apiClient: ApiClient(httpClient: MockClient((req) async {
          paths.add(req.url.path);
          return okJson({
            'ok': true,
            'client': {'id': 'C1', 'email': 'c@example.com', 'fullName': 'عميل', 'phone': '+973'},
          });
        })),
      );

      expect(await app.bootstrap(), BootstrapResult.authenticated);
      expect(paths, contains('/api/mobile/client-auth/session'));
      expect(paths, isNot(contains('/api/mobile/lawyer/session')));
      expect(app.isProfessional, isFalse, reason: 'the client door is not professional');
    });

    test('a stored lawyer token the backend rejects clears the session', () async {
      SharedPreferences.setMockInitialValues(
          {'auth_token': 'revoked', 'account_kind': 'lawyer'});
      final app = AppState(
        apiClient: ApiClient(
          httpClient: MockClient((_) async => http.Response(
                jsonEncode({'ok': false, 'error': 'unauthorized'}),
                401,
                headers: {'content-type': 'application/json'},
              )),
        ),
      );

      expect(await app.bootstrap(), BootstrapResult.sessionExpired);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), isNull);
      expect(prefs.getString('account_kind'), isNull);
      expect(app.isProfessional, isFalse);
    });

    test('logout clears the token, the account kind and the role', () async {
      SharedPreferences.setMockInitialValues(
          {'auth_token': 'lawyer-token', 'account_kind': 'lawyer'});
      final app = AppState(apiClient: failingClient());
      app.currentUser = AppUser(
          id: 'L1', phone: '+97339000002', kind: AccountKind.lawyer, role: 'lawyer');
      expect(app.isProfessional, isTrue);

      await app.logout();

      expect(app.currentUser, isNull);
      expect(app.isProfessional, isFalse, reason: 'the role must not survive logout');
      expect(app.isLoggedIn, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), isNull);
      expect(prefs.getString('account_kind'), isNull);
      expect(prefs.getBool('guest_mode'), isNull);
    });

    test('switching accounts replaces the previous role completely', () async {
      SharedPreferences.setMockInitialValues({});
      final app = AppState(apiClient: failingClient());

      await app.completeLogin('lawyer-token',
          AppUser(id: 'L1', phone: '+973', kind: AccountKind.lawyer, role: 'lawyer'));
      expect(app.isProfessional, isTrue);

      await app.logout();
      await app.completeLogin('client-token',
          AppUser(id: 'C1', phone: '+973', kind: AccountKind.client, role: 'client'));

      expect(app.currentUser!.kind, AccountKind.client);
      expect(app.isProfessional, isFalse, reason: 'the lawyer role must be gone');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('account_kind'), 'client');
      expect(prefs.getString('auth_token'), 'client-token');
    });

    test('continuing as guest drops a previous session and its role', () async {
      SharedPreferences.setMockInitialValues(
          {'auth_token': 'lawyer-token', 'account_kind': 'lawyer'});
      final app = AppState(apiClient: failingClient());
      app.currentUser = AppUser(
          id: 'L1', phone: '+973', kind: AccountKind.lawyer, role: 'lawyer');

      await app.continueAsGuest();

      expect(app.isGuest, isTrue);
      expect(app.currentUser, isNull);
      expect(app.isProfessional, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), isNull);
      expect(prefs.getString('account_kind'), isNull);
      expect(prefs.getBool('guest_mode'), isTrue);
    });

    testWidgets('the login screen offers a lawyer door that asks for a licence',
        (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(apiClient: failingClient()),
          child: const MaterialApp(home: LoginOtpScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('محامٍ'), findsOneWidget);
      expect(find.text('البريد الإلكتروني'), findsOneWidget);

      await tester.tap(find.text('محامٍ'));
      await tester.pump();

      expect(find.text('رقم الترخيص'), findsOneWidget);
      expect(find.text('دخول لوحة المحامي'), findsOneWidget);
      expect(find.text('البريد الإلكتروني'), findsNothing,
          reason: 'the lawyer door asks for a licence, not an email');
    });

    testWidgets('a lawyer identity routes to the lawyer workspace', (tester) async {
      final app = AppState(apiClient: failingClient());
      app.currentUser = AppUser(
          id: 'L1', phone: '+97339000002', kind: AccountKind.lawyer, role: 'lawyer');

      await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
        value: app,
        child: const MaterialApp(home: RootShell()),
      ));
      await tester.pump();

      expect(find.byType(LawyerShell), findsOneWidget);
      expect(find.byType(ClientShell), findsNothing);
    });

    testWidgets('a client identity routes to the client workspace', (tester) async {
      final app = AppState(apiClient: failingClient());
      app.currentUser = AppUser(
          id: 'C1', phone: '+97339000001', kind: AccountKind.client, role: 'client');

      await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
        value: app,
        child: const MaterialApp(home: RootShell()),
      ));
      await tester.pump();

      expect(find.byType(ClientShell), findsOneWidget);
      expect(find.byType(LawyerShell), findsNothing);
    });

    testWidgets('logging out leaves the workspace and lands on login',
        (tester) async {
      final app = AppState(apiClient: failingClient());
      app.currentUser = AppUser(
          id: 'L1', phone: '+97339000002', kind: AccountKind.lawyer, role: 'lawyer');

      await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
        value: app,
        child: const MaterialApp(home: RootShell()),
      ));
      await tester.pump();
      expect(find.byType(LawyerShell), findsOneWidget);

      await app.logout();
      await tester.pump();

      expect(find.byType(LawyerShell), findsNothing,
          reason: 'the lawyer workspace must not outlive the session');
      expect(find.byType(LoginOtpScreen), findsOneWidget);
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

    test('every API path targets a real platform surface', () {
      final pattern = RegExp(r"""['"]/api/[^'"]*""");
      // The platform exposes the mobile API under /api/mobile, the lawyer
      // sign-in at /api/lawyers/login, and the public paid-method catalogue at
      // /api/consultation-methods. Anything else is a web-portal route or a
      // route that does not exist.
      const allowedExact = {'/api/lawyers/login', '/api/consultation-methods'};
      for (final file in dartFiles) {
        for (final match in pattern.allMatches(file.readAsStringSync())) {
          // The match includes the opening quote.
          final path = match.group(0)!.replaceFirst(RegExp(r"""^['"]"""), '');
          final ok = path.startsWith('/api/mobile') || allowedExact.contains(path);
          expect(ok, isTrue,
              reason: 'unexpected endpoint in ${file.path}: $path');
        }
      }
    });
  });
}
