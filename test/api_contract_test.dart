@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lawyers_bh_client/models/user.dart';
import 'package:lawyers_bh_client/providers/app_state.dart';
import 'package:lawyers_bh_client/services/api_client.dart';

/// Full API contract test: drives every Flutter service against a live backend
/// and asserts the real response parses into the models the screens use.
///
///   flutter test --dart-define=API_BASE_URL=http://localhost:8081 \
///     test/api_contract_test.dart
///
/// Skipped (offline) unless API_BASE_URL is provided. Tokens are obtained once
/// per role and shared, so the backend's OTP rate limit is not exhausted.
void main() {
  const baseUrl = String.fromEnvironment('API_BASE_URL');
  final skipReason = baseUrl.isEmpty ? 'set API_BASE_URL to run against a backend' : null;

  final tokens = <String, String>{};
  final users = <String, AppUser>{};
  String? clientToken;
  String? lawyerToken;

  Future<void> loginAs(String phone, String cacheKey) async {
    final app = AppState();
    final data = await app.api.post('/api/v1/auth/otp/request', {'phone': phone});
    final code = data['debug_code']?.toString();
    if (code == null || code.isEmpty) {
      throw StateError('backend returned no debug_code — not running in a non-production env');
    }
    final verify = await app.api.post('/api/v1/auth/otp/verify', {'phone': phone, 'code': code});
    final token = verify['token'] as String;
    app.api.setToken(token);
    tokens[cacheKey] = token;
    users[cacheKey] = await app.auth.me();
  }

  setUpAll(() async {
    if (skipReason != null) return;
    await loginAs('+97339000001', 'client');
    await loginAs('+97339000003', 'lawyer');
    clientToken = tokens['client'];
    lawyerToken = tokens['lawyer'];
  });

  AppState authedApp(String token) {
    SharedPreferences.setMockInitialValues({});
    final app = AppState();
    app.api.setToken(token);
    return app;
  }

  test('reference data and lawyer directory parse', () async {
    final app = authedApp(clientToken!);

    final categories = await app.lawyers.categories();
    expect(categories, isNotEmpty, reason: 'categories');
    expect(categories.first.nameAr, isNotEmpty);

    final specs = await app.lawyers.specializations();
    expect(specs, isNotEmpty, reason: 'specializations');

    final services = await app.lawyer.serviceCatalogue();
    expect(services, isNotEmpty, reason: 'services');

    final docCategories = await app.documents.categories();
    expect(docCategories, isNotEmpty, reason: 'document-categories');

    final lawyers = await app.lawyers.search();
    expect(lawyers, isNotEmpty, reason: 'lawyers directory');
    final first = lawyers.first;
    expect(first.name, isNotEmpty, reason: 'lawyer name');
    expect(first.consultationFee, greaterThan(0), reason: 'consultation_fee parsed');

    final detail = await app.lawyers.detail(first.id);
    expect(detail.name, isNotEmpty);
  }, skip: skipReason);

  test('client identity: token, role, permissions from /auth/me', () async {
    final user = users['client']!;
    expect(tokens['client'], isNotEmpty, reason: 'token received');
    expect(user.role, 'client');
    expect(user.isProfessional, isFalse, reason: 'client must not be professional');
    expect(user.roles, contains('client'), reason: 'roles folded from /auth/me');
    expect(user.permissions, isNotEmpty, reason: 'permissions folded from /auth/me');
    expect(user.can('cases.view'), isTrue);
  }, skip: skipReason);

  test('client flow: booking, case, contract, sign, payment', () async {
    final app = authedApp(clientToken!);

    final lawyer = (await app.lawyers.search()).first;
    final (caseId, contractId) = await app.cases.bookConsultation(
      lawyerId: lawyer.id,
      consultType: 'video',
      subject: 'متابعة تكامل',
    );
    expect(caseId, greaterThan(0));
    expect(contractId, greaterThan(0));

    final contracts = await app.cases.myContracts();
    expect(contracts.map((c) => c.id), contains(contractId), reason: 'my contracts');

    final contract = await app.cases.contractDetail(contractId);
    expect(contract.id, contractId);
    expect(contract.lawyerName, isNotEmpty, reason: 'contract lawyer_name');
    expect(contract.feeAmount, greaterThan(0), reason: 'contract fee_amount');

    final cases = await app.cases.myCases();
    expect(cases.map((c) => c.id), contains(caseId), reason: 'my cases');
    final detail = await app.cases.caseDetail(caseId);
    expect(detail.title, isNotEmpty);

    await app.cases.signContract(contractId, 'data:image/png;base64,iVBORw0KGgo=');
    final after = await app.cases.contractDetail(contractId);
    expect(after.status, isNot('awaiting_signature'),
        reason: 'contract leaves awaiting_signature after signing');

    final payment = await app.payments.create(contractId: contractId, method: 'benefitpay');
    expect(payment.id, greaterThan(0), reason: 'payment id');
    expect(payment.amount, greaterThan(0), reason: 'payment amount');

    final payments = await app.payments.myPayments();
    expect(payments.map((p) => p.id), contains(payment.id), reason: 'my payments');
  }, skip: skipReason);

  test('client protected listings parse (empty-safe)', () async {
    final app = authedApp(clientToken!);

    expect(await app.messages.conversations(), isNotNull);
    final (notes, unread) = await app.notifications.list();
    expect(notes, isNotNull);
    expect(unread, greaterThanOrEqualTo(0));
    expect(await app.documents.list(), isNotNull);
    expect(await app.payments.myPayments(), isNotNull);
  }, skip: skipReason);

  test('client must NOT reach the legal CRM (permission enforced)', () async {
    final app = authedApp(clientToken!);
    await expectLater(
      app.leads.list(),
      throwsA(isA<ApiException>().having((e) => e.error, 'error', 'forbidden')),
    );
  }, skip: skipReason);

  test('lawyer identity + flow: profile, leads, cases, availability', () async {
    final user = users['lawyer']!;
    expect(user.isProfessional, isTrue, reason: 'lawyer must be professional');

    final app = authedApp(lawyerToken!);
    final profile = await app.lawyer.profile();
    expect(profile.professionalName, isNotEmpty, reason: 'lawyer profile parses');

    expect(await app.leads.list(), isNotNull, reason: 'leads list');
    expect(await app.cases.myCases(), isNotNull);
    expect(await app.lawyer.blockedDates(), isNotNull);
    expect(await app.lawyer.specializations(), isNotEmpty);
  }, skip: skipReason);

  test('invalid token is rejected by /auth/me', () async {
    final app = authedApp('not-a-real-token');
    await expectLater(
      app.auth.me(),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401)),
    );
  }, skip: skipReason);
}
