import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lawyers_bh_client/models/user.dart';
import 'package:lawyers_bh_client/providers/app_state.dart';
import 'package:lawyers_bh_client/screens/lawyer_cases_screen.dart';
import 'package:lawyers_bh_client/services/api_client.dart';

/// Regression tests for the permanent-spinner bugs.
///
/// They drive the real [ApiClient] and real screens through an injected
/// transport, so the production request/parse/state code runs — only the
/// socket is controlled. No mocks of app logic.
http.Response _envelope(Object? data) => http.Response(
      jsonEncode({'success': true, 'data': data, 'message': null}),
      200,
      headers: {'content-type': 'application/json'},
    );

AppUser _user(String role) =>
    AppUser(id: 1, phone: '+97339000001', name: 'T', role: role, roles: [role]);

void main() {
  group('ApiClient request timeout', () {
    test('a socket that never answers surfaces as network_timeout', () async {
      final client = ApiClient(
        requestTimeout: const Duration(milliseconds: 40),
        httpClient: MockClient((_) async => Completer<http.Response>().future),
      );

      await expectLater(
        client.get('/api/v1/categories'),
        throwsA(isA<ApiException>()
            .having((e) => e.error, 'error', 'network_timeout')),
      );
    });

    test('a transport failure surfaces as network_error, not a hang', () async {
      final client = ApiClient(
        httpClient: MockClient((_) async => throw http.ClientException("refused")),
      );

      await expectLater(
        client.get('/api/v1/categories'),
        throwsA(
            isA<ApiException>().having((e) => e.error, 'error', 'network_error')),
      );
    });
  });

  group('session expiry', () {
    test('a mid-session 401 clears the session and flags it', () async {
      SharedPreferences.setMockInitialValues({});
      // Login succeeds; the *next* call is rejected, as if the token expired
      // while the app was open.
      var calls = 0;
      final app = AppState(
        apiClient: ApiClient(
          httpClient: MockClient((_) async {
            calls++;
            if (calls == 1) {
              return _envelope({
                'user': {
                  'id': 1,
                  'phone': '+97339000001',
                  'name': 'T',
                  'role': 'client',
                },
                'roles': ['client'],
                'permissions': <String>[],
              });
            }
            return http.Response(
              jsonEncode({'success': false, 'error': 'unauthenticated'}),
              401,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );
      await app.completeLogin('token', _user('client'));
      expect(app.currentUser, isNotNull);

      await expectLater(app.auth.me(), throwsA(isA<ApiException>()));

      expect(app.sessionExpired, isTrue, reason: 'the shell must be told');
      expect(app.currentUser, isNull, reason: 'the dead session is dropped');
      expect(app.isLoggedIn, isFalse);
    });

    test('a 403 permission denial does NOT log the user out', () async {
      SharedPreferences.setMockInitialValues({});
      var calls = 0;
      final app = AppState(
        apiClient: ApiClient(
          httpClient: MockClient((_) async {
            calls++;
            if (calls == 1) {
              return _envelope({
                'user': {'id': 1, 'phone': '+97339000001', 'role': 'client'},
                'roles': ['client'],
                'permissions': <String>[],
              });
            }
            return http.Response(
              jsonEncode({'success': false, 'error': 'forbidden'}),
              403,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );
      await app.completeLogin('token', _user('client'));

      await expectLater(app.auth.me(), throwsA(isA<ApiException>()));

      expect(app.sessionExpired, isFalse, reason: '403 is not an expiry');
      expect(app.currentUser, isNotNull, reason: 'the session is still valid');
    });

    test('a 401 while logged out is ignored (wrong OTP code)', () async {
      SharedPreferences.setMockInitialValues({});
      final app = AppState(
        apiClient: ApiClient(
          httpClient: MockClient((_) async => http.Response(
                jsonEncode({'success': false, 'error': 'invalid_or_expired_code'}),
                401,
                headers: {'content-type': 'application/json'},
              )),
        ),
      );

      await expectLater(app.auth.sendOtp('+97339000001'),
          throwsA(isA<ApiException>()));
      expect(app.sessionExpired, isFalse);
    });
  });

  group('lawyer case list loading state', () {
    testWidgets('a parse failure clears the spinner and offers a retry',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      // `cases` is absent: the screen's real parser throws a cast error — the
      // exact non-ApiException path that used to leave the spinner forever.
      final app = AppState(
        apiClient: ApiClient(httpClient: MockClient((_) async => _envelope({}))),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: app,
          child: const MaterialApp(home: LawyerCasesScreen()),
        ),
      );
      await tester.pump(); // start the request
      await tester.pump(const Duration(milliseconds: 50)); // let it settle

      expect(find.byType(CircularProgressIndicator), findsNothing,
          reason: 'loading must be reset even when parsing fails');
      expect(find.text('تعذّر تحميل القضايا'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });

    testWidgets('a hung request ends in an error, not a spinner', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final app = AppState(
        apiClient: ApiClient(
          requestTimeout: const Duration(milliseconds: 30),
          httpClient: MockClient((_) async => Completer<http.Response>().future),
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: app,
          child: const MaterialApp(home: LawyerCasesScreen()),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 80));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });

    testWidgets('real data renders the list and no spinner', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final app = AppState(
        apiClient: ApiClient(
          httpClient: MockClient((_) async => _envelope({
                'cases': [
                  {'id': 7, 'title': 'قضية تجارية', 'status': 'active'},
                ],
              })),
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: app,
          child: const MaterialApp(home: LawyerCasesScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('قضية تجارية'), findsOneWidget);
    });
  });
}
