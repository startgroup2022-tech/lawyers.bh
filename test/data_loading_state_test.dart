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
import 'package:lawyers_bh_client/screens/lawyers_directory_screen.dart';
import 'package:lawyers_bh_client/services/api_client.dart';

/// Regression tests for the permanent-spinner bugs.
///
/// They drive the real [ApiClient] and real screens through an injected
/// transport, so the production request/parse/state code runs — only the
/// socket is controlled. No mocks of app logic.
///
/// The screens are backed by a real endpoint (`GET /api/mobile/lawyers`), so a
/// green run means the shipped service + screen clear their loading state on
/// the success, error and timeout paths.
http.Response _ok(Object? payload) => http.Response(
      jsonEncode({'ok': true, ...payload as Map<String, dynamic>}),
      200,
      headers: {'content-type': 'application/json'},
    );

http.Response _fail(String error, int status) => http.Response(
      jsonEncode({'ok': false, 'error': error}),
      status,
      headers: {'content-type': 'application/json'},
    );

AppUser _user(String role) =>
    AppUser(id: '1', phone: '+97339000001', name: 'T', role: role, roles: [role]);

Widget _directory(ApiClient client) => ChangeNotifierProvider<AppState>.value(
      value: AppState(apiClient: client),
      // The screen is a tab body in the app, so the shell supplies the
      // Scaffold/Material ancestor; the test supplies one too.
      child: const MaterialApp(
        home: Scaffold(body: LawyersDirectoryScreen()),
      ),
    );

void main() {
  group('ApiClient request timeout', () {
    test('a socket that never answers surfaces as network_timeout', () async {
      final client = ApiClient(
        requestTimeout: const Duration(milliseconds: 40),
        httpClient: MockClient((_) async => Completer<http.Response>().future),
      );

      await expectLater(
        client.get('/api/mobile/lawyers', query: {'countryCode': 'BH'}),
        throwsA(isA<ApiException>()
            .having((e) => e.error, 'error', 'network_timeout')),
      );
    });

    test('a transport failure surfaces as network_error, not a hang', () async {
      final client = ApiClient(
        httpClient: MockClient((_) async => throw http.ClientException('refused')),
      );

      await expectLater(
        client.get('/api/mobile/lawyers', query: {'countryCode': 'BH'}),
        throwsA(
            isA<ApiException>().having((e) => e.error, 'error', 'network_error')),
      );
    });
  });

  group('session expiry', () {
    test('a mid-session 401 clears the session and flags it', () async {
      SharedPreferences.setMockInitialValues({});
      final app = AppState(
        apiClient: ApiClient(
          httpClient: MockClient((_) async => _fail('unauthorized', 401)),
        ),
      );
      await app.completeLogin('token', _user('client'));
      expect(app.currentUser, isNotNull);

      await expectLater(app.auth.session(), throwsA(isA<ApiException>()));

      expect(app.sessionExpired, isTrue, reason: 'the shell must be told');
      expect(app.currentUser, isNull, reason: 'the dead session is dropped');
      expect(app.isLoggedIn, isFalse);
    });

    test('a 403 permission denial does NOT log the user out', () async {
      SharedPreferences.setMockInitialValues({});
      final app = AppState(
        apiClient: ApiClient(
          httpClient: MockClient((_) async => _fail('forbidden', 403)),
        ),
      );
      await app.completeLogin('token', _user('client'));

      await expectLater(app.auth.session(), throwsA(isA<ApiException>()));

      expect(app.sessionExpired, isFalse, reason: '403 is not an expiry');
      expect(app.currentUser, isNotNull, reason: 'the session is still valid');
    });

    test('a 401 while logged out is ignored (wrong credentials)', () async {
      SharedPreferences.setMockInitialValues({});
      final app = AppState(
        apiClient: ApiClient(
          httpClient: MockClient((_) async => _fail('invalid_credentials', 401)),
        ),
      );

      await expectLater(app.auth.login('a@b.co', 'password123'),
          throwsA(isA<ApiException>()));
      expect(app.sessionExpired, isFalse);
    });
  });

  group('lawyer directory loading state', () {
    testWidgets('a backend error clears the spinner and offers a retry',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_directory(
        ApiClient(httpClient: MockClient((_) async => _fail('server_error', 500))),
      ));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing,
          reason: 'loading must be reset when the request fails');
      expect(find.text('تعذّر تحميل النتائج'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });

    testWidgets('a hung request ends in an error, not a spinner', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_directory(ApiClient(
        requestTimeout: const Duration(milliseconds: 30),
        httpClient: MockClient((_) async => Completer<http.Response>().future),
      )));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 80));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });

    testWidgets('real data renders the list and no spinner', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_directory(ApiClient(
        httpClient: MockClient((_) async => _ok({
              'countryCode': 'BH',
              'data': [
                {
                  'id': 'e449b317-cfb6-4128-ad37-cba515a23e85',
                  'countryCode': 'BH',
                  'fullNameAr': 'محمد ناجي',
                  'fullNameEn': 'MOHAMED NAJI',
                  'status': 'approved',
                  'subscriptionType': 'lawyer',
                },
              ],
            })),
      )));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('محمد ناجي'), findsOneWidget);
    });
  });
}
