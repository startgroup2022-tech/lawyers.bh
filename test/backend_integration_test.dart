@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lawyers_bh_client/providers/app_state.dart';
import 'package:lawyers_bh_client/services/api_client.dart';

/// End-to-end check against the live platform.
///
/// Skipped unless a base URL is provided, so the default `flutter test` run is
/// fully offline:
///
///   flutter test --dart-define=API_BASE_URL=https://www.lawyers.bh \
///     test/backend_integration_test.dart
///
/// It drives the real [AppState] and its services. The auth cases deliberately
/// use *rejected* credentials, so the run never creates an account or sends an
/// email; the point is to prove the app speaks the real contract and that a
/// session which cannot be validated fails safely.
void main() {
  const baseUrl = String.fromEnvironment('API_BASE_URL');
  final skipReason = baseUrl.isEmpty ? 'set API_BASE_URL to run against the backend' : null;

  test('the public directory loads without a session (guest browsing)', () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    expect(await state.bootstrap(), BootstrapResult.firstRun);
    await state.continueAsGuest();
    expect(state.isGuest, isTrue);
    expect(state.isLoggedIn, isFalse);

    final lawyers = await state.lawyers.directory();
    expect(lawyers, isNotEmpty, reason: 'guest can browse the directory');
  }, skip: skipReason);

  test('bootstrap reports sessionExpired for a bogus token', () async {
    SharedPreferences.setMockInitialValues({'auth_token': 'not-a-real-token'});
    final state = AppState();
    expect(await state.bootstrap(), BootstrapResult.sessionExpired);
  }, skip: skipReason);

  test('a valid-looking but rejected login surfaces the backend code', () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await expectLater(
      state.auth.login('definitely-not-registered@example.com', 'password123'),
      throwsA(isA<ApiException>()),
    );
    expect(state.isLoggedIn, isFalse);
  }, skip: skipReason);

  test('features without a client endpoint fail loudly, not silently', () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await expectLater(
      state.cases.myCases(),
      throwsA(isA<ApiException>()
          .having((e) => e.error, 'error', 'feature_not_available')),
    );
  }, skip: skipReason);
}
