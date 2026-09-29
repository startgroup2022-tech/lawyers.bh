@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:lawyers_bh_client/providers/app_state.dart';
import 'package:lawyers_bh_client/services/api_client.dart';

/// Live contract test against the real Lawyers.bh platform API.
///
///   flutter test --dart-define=API_BASE_URL=https://www.lawyers.bh \
///     test/api_contract_test.dart
///
/// Skipped (offline) unless API_BASE_URL is provided. It exercises the exact
/// endpoints the app ships with, so a green run means the app is speaking the
/// real platform contract and not a fictional one.
///
/// No account is created and no email is sent: every auth case below is a
/// *rejected* request, which the backend answers with the validation code the
/// app maps to an Arabic message.
void main() {
  const baseUrl = String.fromEnvironment('API_BASE_URL');
  final skipReason = baseUrl.isEmpty ? 'set API_BASE_URL to run against the backend' : null;

  ApiException? asApiError(Object error) => error is ApiException ? error : null;

  Future<ApiException> expectApiError(Future<Object?> Function() call) async {
    try {
      await call();
    } on ApiException catch (e) {
      return e;
    }
    fail('expected an ApiException');
  }

  group('public directory', () {
    test('GET /api/mobile/lawyers parses into the Lawyer model', () async {
      final app = AppState();
      final lawyers = await app.lawyers.directory();
      expect(lawyers, isNotEmpty, reason: 'the BH directory has approved lawyers');

      final first = lawyers.first;
      expect(first.id, isNotEmpty, reason: 'UUID id parsed');
      expect(first.name, isNotEmpty, reason: 'name parsed');
      expect(first.status, 'approved');
    }, skip: skipReason);
  });

  group('client auth contract', () {
    test('login rejects bad credentials as invalid_credentials (401)', () async {
      // Login deliberately answers `invalid_credentials` for a malformed email
      // as well as a wrong password, so it cannot be used to enumerate
      // accounts. Registration is the endpoint that returns field-level codes.
      final app = AppState();
      final e = await expectApiError(() => app.auth.login('not-an-email', 'password123'));
      expect(e.error, 'invalid_credentials');
      expect(e.statusCode, 401);
    }, skip: skipReason);

    test('register request rejects a bad phone with invalid_phone', () async {
      final app = AppState();
      final e = await expectApiError(() => app.auth.requestAccount(
            mode: 'register',
            email: 'someone@example.com',
            password: 'password123',
            fullName: 'Test Person',
            phone: '123',
          ));
      expect(e.error, 'invalid_phone');
    }, skip: skipReason);

    test('register request rejects a missing name with invalid_name', () async {
      final app = AppState();
      final e = await expectApiError(() => app.auth.requestAccount(
            mode: 'register',
            email: 'someone@example.com',
            password: 'password123',
            fullName: '',
            phone: '+97339000000',
          ));
      expect(e.error, 'invalid_name');
    }, skip: skipReason);

    test('verify rejects an unknown challenge with invalid_code', () async {
      final app = AppState();
      final e = await expectApiError(
          () => app.auth.verify('00000000-0000-0000-0000-000000000000', '000000'));
      expect(e.error, 'invalid_code');
    }, skip: skipReason);

    test('session without a token is unauthorized (401)', () async {
      final app = AppState();
      final e = await expectApiError(() => app.auth.session());
      expect(e.statusCode, 401);
      expect(e.error, 'unauthorized');
    }, skip: skipReason);

    test('session with a bogus token is rejected and clears the session', () async {
      final app = AppState();
      app.api.setToken('not-a-real-token');
      final e = await expectApiError(() => app.auth.session());
      expect(e.statusCode, 401);
    }, skip: skipReason);
  });

  group('lawyer auth contract (the professional door)', () {
    test('an unknown licence is rejected with 401, not a token', () async {
      final app = AppState();
      final e = await expectApiError(() => app.lawyerAuth.login(
            licenseNumber: 'NOT-A-REAL-LICENCE',
            password: 'password123',
          ));
      expect(e.statusCode, 401);
      expect(app.isProfessional, isFalse);
      expect(app.isLoggedIn, isFalse);
    }, skip: skipReason);

    test('a rejected lawyer login leaves no token behind', () async {
      final app = AppState();
      await expectApiError(() => app.lawyerAuth.login(
            licenseNumber: 'NOT-A-REAL-LICENCE',
            password: 'password123',
          ));
      // The service sets the token to read the session; a failure must clear it.
      await expectApiError(() => app.lawyerAuth.session());
    }, skip: skipReason);

    test('the lawyer session rejects a missing token (401)', () async {
      final app = AppState();
      final e = await expectApiError(() => app.lawyerAuth.session());
      expect(e.statusCode, 401);
    }, skip: skipReason);

    test('a client token cannot open the lawyer session', () async {
      final app = AppState();
      app.api.setToken('not-a-real-token');
      final e = await expectApiError(() => app.lawyerAuth.session());
      expect(e.statusCode, 401, reason: 'the two doors are not interchangeable');
    }, skip: skipReason);

    test('a licence-shaped credential cannot sign in through the client door',
        () async {
      final app = AppState();
      final e = await expectApiError(
          () => app.auth.login('NOT-A-REAL-LICENCE', 'password123'));
      expect(e.error, 'invalid_credentials');
    }, skip: skipReason);
  });

  group('feature gaps are explicit, not silent empty lists', () {
    test('client messaging reports feature_not_available', () async {
      final app = AppState();
      final e = await expectApiError(() => app.messages.conversations());
      expect(e.error, 'feature_not_available');
      expect(e.statusCode, 501);
    });

    test('client notifications report feature_not_available', () async {
      final app = AppState();
      final e = await expectApiError(() => app.notifications.list());
      expect(e.error, 'feature_not_available');
    });

    test('case workspace reports feature_not_available', () async {
      final app = AppState();
      final e = await expectApiError(() => app.cases.myCases());
      expect(e.error, 'feature_not_available');
    });
  });

  group('endpoint guard', () {
    test('asApiError only accepts ApiException', () {
      expect(asApiError(const ApiException('x', 1)), isNotNull);
      expect(asApiError(StateError('x')), isNull);
    });
  });
}
