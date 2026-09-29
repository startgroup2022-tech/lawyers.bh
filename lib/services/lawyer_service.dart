import '../models/lawyer_profile.dart';
import 'api_client.dart';

/// The professional (lawyer) endpoints the mobile API exposes.
///
/// A lawyer signs in with their licence number and password
/// (`POST /api/lawyers/login`), which returns a mobile lawyer session token.
/// That token unlocks the lawyer's own session, earnings, withdrawals, profile
/// editor, weekly availability grid and blocked dates. The lead pipeline and
/// document vault remain web-portal surfaces and are reported as unavailable
/// rather than silently faked.
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

  /// The lawyer's own profile, including the weekly availability grid
  /// (`GET /api/mobile/lawyer/profile`).
  Future<LawyerProfile> profile() async {
    final data = await api.get('/api/mobile/lawyer/profile');
    final profile = data['profile'];
    if (profile is Map<String, dynamic>) return LawyerProfile.fromJson(profile);
    throw const ApiException('invalid_server_response', 200);
  }

  /// Saves the profile editor (`PATCH /api/mobile/lawyer/profile`). The payload
  /// is sent as the editor builds it; unknown keys are ignored server-side.
  Future<LawyerProfile> updateProfile(Map<String, dynamic> payload) async {
    final data = await api.patch('/api/mobile/lawyer/profile', payload);
    final profile = data['profile'];
    if (profile is Map<String, dynamic>) return LawyerProfile.fromJson(profile);
    throw const ApiException('invalid_server_response', 200);
  }

  /// Replaces the whole weekly grid (`PUT /api/mobile/lawyer/availability`).
  Future<void> syncAvailability(List<Map<String, dynamic>> slots) async {
    await api.put('/api/mobile/lawyer/availability', {'availability': slots});
  }

  /// The lawyer's blocked dates (`GET /api/mobile/lawyer/blocked-dates`).
  Future<List<BlockedDate>> blockedDates({String? from, String? to}) async {
    final data = await api.get('/api/mobile/lawyer/blocked-dates');
    final rows = data['blockedDates'];
    if (rows is! List) return const [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(BlockedDate.fromJson)
        .toList(growable: false);
  }

  /// Blocks a date or a time range inside it
  /// (`POST /api/mobile/lawyer/blocked-dates`). Returns the new id.
  Future<String> blockDate({
    required String date,
    bool allDay = true,
    String? startTime,
    String? endTime,
    String reasonType = 'other',
    String? reason,
  }) async {
    final data = await api.post('/api/mobile/lawyer/blocked-dates', {
      'date': date,
      'allDay': allDay,
      if (!allDay) 'startTime': startTime,
      if (!allDay) 'endTime': endTime,
      'reasonType': reasonType,
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });
    return '${data['id']}';
  }

  /// Removes one of the lawyer's own blocked dates.
  Future<void> unblockDate(String id) async {
    await api.delete('/api/mobile/lawyer/blocked-dates?id=$id');
  }

  // ---- Web-portal only: no mobile endpoint -------------------------------

  Future<void> syncSpecializations(List<int> ids) async => throw _unavailable();

  Future<void> syncServices(List<int> ids) async => throw _unavailable();

  Future<List<(int, String)>> specializations() async => throw _unavailable();

  Future<List<Map<String, dynamic>>> serviceCatalogue() async => throw _unavailable();
}
