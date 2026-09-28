import '../models/lawyer_profile.dart';
import 'api_client.dart';

/// The professional (lawyer) endpoints the mobile API actually exposes.
///
/// A lawyer signs in with their licence number and password
/// (`POST /api/lawyers/login`), which returns a mobile lawyer session token.
/// That token unlocks the lawyer's own session, earnings and withdrawals —
/// **not** a general profile editor, availability grid, lead pipeline or
/// document vault, which live in the lawyer web portal. Those are reported as
/// unavailable rather than silently faked.
class LawyerService {
  final ApiClient api;
  LawyerService(this.api);

  static ApiException _unavailable() => ApiException.featureUnavailable(
        'هذه الميزة متاحة في بوابة المحامي على الويب',
      );

  /// The lawyer's own account summary (`GET /api/mobile/lawyer/session`).
  Future<Map<String, dynamic>> session() async {
    final data = await api.get('/api/mobile/lawyer/session');
    final lawyer = data['lawyer'];
    if (lawyer is Map<String, dynamic>) return lawyer;
    throw const ApiException('invalid_server_response', 200);
  }

  /// Earnings summary (`GET /api/mobile/lawyer/earnings`).
  Future<Map<String, dynamic>> earnings() => api.get('/api/mobile/lawyer/earnings');

  /// Withdrawal history (`GET /api/mobile/lawyer/withdrawals`).
  Future<Map<String, dynamic>> withdrawals() => api.get('/api/mobile/lawyer/withdrawals');

  // ---- Web-portal only: no mobile endpoint -------------------------------

  Future<LawyerProfile> profile() async => throw _unavailable();

  Future<void> updateProfile(Map<String, dynamic> payload) async => throw _unavailable();

  Future<void> syncAvailability(List<Map<String, dynamic>> slots) async =>
      throw _unavailable();

  Future<void> syncSpecializations(List<int> ids) async => throw _unavailable();

  Future<void> syncServices(List<int> ids) async => throw _unavailable();

  Future<List<BlockedDate>> blockedDates({String? from, String? to}) async =>
      throw _unavailable();

  Future<int> blockDate({
    required String date,
    bool allDay = true,
    String? startTime,
    String? endTime,
    String reasonType = 'other',
    String? reason,
  }) async =>
      throw _unavailable();

  Future<void> unblockDate(int id) async => throw _unavailable();

  Future<List<(int, String)>> specializations() async => throw _unavailable();

  Future<List<Map<String, dynamic>>> serviceCatalogue() async => throw _unavailable();
}
