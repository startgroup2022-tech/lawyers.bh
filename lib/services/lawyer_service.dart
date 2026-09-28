import '../models/lawyer_profile.dart';
import 'api_client.dart';

/// Talks to the professional (lawyer) endpoints under `/api/v1/lawyer/*`.
///
/// Every call here requires a token whose account holds a lawyer role; the
/// backend rejects anyone else.
class LawyerService {
  final ApiClient api;
  LawyerService(this.api);

  /// The caller's own lawyer profile with specializations, services,
  /// availability and verification history.
  Future<LawyerProfile> profile() async {
    final data = await api.get('/api/v1/lawyer/profile');
    final lawyer = Map<String, dynamic>.from(data['lawyer'] as Map);
    // The endpoint returns the related collections as siblings of `lawyer`;
    // fold them in so the model is built from one map.
    lawyer['specializations'] = data['specializations'];
    lawyer['services'] = data['services'];
    lawyer['availability'] = data['availability'];
    lawyer['verification'] = data['verification'];
    return LawyerProfile.fromJson(lawyer);
  }

  /// Updates the profile. `PATCH` expects the full editable payload: the
  /// backend writes every validated field, so omitted nullable columns are
  /// nulled. Callers should send the complete set they intend to keep.
  Future<void> updateProfile(Map<String, dynamic> payload) =>
      api.patch('/api/v1/lawyer/profile', payload);

  /// Replaces the weekly availability with `slots`.
  Future<void> syncAvailability(List<Map<String, dynamic>> slots) =>
      api.put('/api/v1/lawyer/availability', {'availability': slots});

  /// Replaces the specializations with `ids` (with the first marked primary).
  Future<void> syncSpecializations(List<int> ids) =>
      api.put('/api/v1/lawyer/specializations', {
        'specializations': [
          for (var i = 0; i < ids.length; i++) {'specialization_id': ids[i], 'is_primary': i == 0},
        ],
      });

  /// Replaces the offered services with `ids`.
  Future<void> syncServices(List<int> ids) =>
      api.put('/api/v1/lawyer/services', {
        'services': [for (final id in ids) {'service_id': id}],
      });

  Future<List<BlockedDate>> blockedDates({String? from, String? to}) async {
    final data = await api.get('/api/v1/lawyer/blocked-dates', query: {
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    });
    return (data['blocked_dates'] as List)
        .map((e) => BlockedDate.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> blockDate({
    required String date,
    bool allDay = true,
    String? startTime,
    String? endTime,
    String reasonType = 'other',
    String? reason,
  }) async {
    final data = await api.post('/api/v1/lawyer/blocked-dates', {
      'blocked_date': date,
      'all_day': allDay,
      if (!allDay && startTime != null) 'start_time': startTime,
      if (!allDay && endTime != null) 'end_time': endTime,
      'reason_type': reasonType,
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });
    return int.parse('${data['id']}');
  }

  Future<void> unblockDate(int id) => api.delete('/api/v1/lawyer/blocked-dates/$id');

  /// The specialization catalogue a lawyer can pick from.
  Future<List<(int, String)>> specializations() async {
    final data = await api.get('/api/v1/specializations');
    return (data['specializations'] as List)
        .map((e) => (int.parse('${e['id']}'), '${e['name_ar']}'))
        .toList();
  }

  /// The service catalogue with fees, used by the services editor.
  Future<List<Map<String, dynamic>>> serviceCatalogue() async {
    final data = await api.get('/api/v1/services');
    return (data['services'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
