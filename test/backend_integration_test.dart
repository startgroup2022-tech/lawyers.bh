@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lawyers_bh_client/providers/app_state.dart';

/// End-to-end check against a live backend.
///
/// Skipped unless a base URL is provided, so the default `flutter test` run is
/// fully offline:
///
///   flutter test --dart-define=API_BASE_URL=http://localhost:8081 \
///     test/backend_integration_test.dart
///
/// It drives the real [AppState] and its services, so a green run means the
/// canonical `/api/v1/auth/*` flow the app ships with actually works.
void main() {
  const baseUrl = String.fromEnvironment('API_BASE_URL');
  final skipReason = baseUrl.isEmpty ? 'set API_BASE_URL to run against a backend' : null;

  test('OTP login reaches /auth/me and restores the session', () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    final phone = '+9733${(DateTime.now().microsecondsSinceEpoch % 10000000).toString().padLeft(7, '0')}';

    // A single request; the backend returns the code outside production so the
    // flow can be completed without SMS. (A second request would hit the
    // resend cooldown.)
    final code = await _requestCode(state, phone);
    final (token, user) = await state.auth.verifyOtp(phone, code);

    await state.completeLogin(token, user);
    expect(state.isLoggedIn, isTrue);
    expect(state.isGuest, isFalse);
    expect(user.role, 'client');
    expect(state.isProfessional, isFalse);
  }, skip: skipReason);

  test('a lawyer account routes to the professional workspace', () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    // Seeded demo lawyer account.
    final code = await _requestCode(state, '+97339000002');
    final (token, user) = await state.auth.verifyOtp('+97339000002', code);
    await state.completeLogin(token, user);
    expect(state.isLoggedIn, isTrue);
    expect(state.isProfessional, isTrue);
  }, skip: skipReason);

  test('bootstrap reports sessionExpired for a bogus token', () async {
    SharedPreferences.setMockInitialValues({'auth_token': 'not-a-real-token'});
    final state = AppState();
    expect(await state.bootstrap(), BootstrapResult.sessionExpired);
  }, skip: skipReason);

  test('guest browsing never leaves isLoggedIn true', () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.bootstrap();
    await state.continueAsGuest();
    expect(state.isGuest, isTrue);
    expect(state.isLoggedIn, isFalse);
    // Public catalogues are reachable without a token.
    final categories = await state.lawyers.categories();
    expect(categories, isNotEmpty);
  }, skip: skipReason);
}

/// Requests a fresh OTP and reads the development `debug_code`.
Future<String> _requestCode(AppState state, String phone) async {
  final data = await state.api.post('/api/v1/auth/otp/request', {'phone': phone});
  final code = data['debug_code']?.toString();
  if (code == null || code.isEmpty) {
    throw StateError('backend did not return a debug_code (is it running in production?)');
  }
  return code;
}
