import '../models/lead.dart';
import 'api_client.dart';

/// The Legal CRM surface: the lead pipeline and its activity trail.
///
/// The backend scopes visibility by role, so this service never filters
/// client-side; it shows exactly what the account is allowed to see.
class LeadsService {
  final ApiClient api;
  LeadsService(this.api);

  Future<List<Lead>> list({String? status, String? priority}) async {
    final data = await api.get('/api/v1/leads', query: {
      if (status != null && status.isNotEmpty) 'status': status,
      if (priority != null && priority.isNotEmpty) 'priority': priority,
    });
    return (data['leads'] as List).map((e) => Lead.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<(Lead lead, List<LeadActivity> activities)> detail(int id) async {
    final data = await api.get('/api/v1/leads/$id');
    final lead = Lead.fromJson(data['lead'] as Map<String, dynamic>);
    final activities = (data['activities'] as List?)
            ?.map((e) => LeadActivity.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const <LeadActivity>[];
    return (lead, activities);
  }

  Future<int> create({
    required String subject,
    String? description,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    int? specializationId,
    String priority = 'normal',
    String source = 'app',
    double? estimatedValue,
    int? assignedLawyerId,
  }) async {
    final data = await api.post('/api/v1/leads', {
      'subject': subject,
      if (description != null) 'description': description,
      if (contactName != null) 'contact_name': contactName,
      if (contactPhone != null) 'contact_phone': contactPhone,
      if (contactEmail != null) 'contact_email': contactEmail,
      if (specializationId != null) 'specialization_id': specializationId,
      'priority': priority,
      'source': source,
      if (estimatedValue != null) 'estimated_value': estimatedValue,
      if (assignedLawyerId != null) 'assigned_lawyer_id': assignedLawyerId,
    });
    return int.parse('${data['id']}');
  }

  /// Advances a lead's pipeline state or edits its details.
  Future<void> update(
    int id, {
    String? status,
    String? priority,
    String? nextAction,
    double? estimatedValue,
    String? lostReason,
    int? assignedLawyerId,
  }) =>
      api.patch('/api/v1/leads/$id', {
        if (status != null) 'status': status,
        if (priority != null) 'priority': priority,
        if (nextAction != null) 'next_action': nextAction,
        if (estimatedValue != null) 'estimated_value': estimatedValue,
        if (lostReason != null) 'lost_reason': lostReason,
        if (assignedLawyerId != null) 'assigned_lawyer_id': assignedLawyerId,
      });

  /// Appends an entry to the lead's activity trail.
  Future<int> addActivity(int id, {required String type, required String notes}) async {
    final data = await api.post('/api/v1/leads/$id/activities', {
      'activity_type': type,
      'notes': notes,
    });
    return int.parse('${data['id']}');
  }

  /// Turns a lead into a case. Returns the new case id.
  Future<int> convert(int id, {String? caseType, String? priority, String? title}) async {
    final data = await api.post('/api/v1/leads/$id/convert', {
      if (caseType != null) 'case_type': caseType,
      if (priority != null) 'priority': priority,
      if (title != null) 'title': title,
    });
    final caseId = data['case_id'] ?? (data['case'] as Map?)?['id'];
    return int.parse('$caseId');
  }
}
