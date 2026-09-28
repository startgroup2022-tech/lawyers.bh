/// A sales/CRM lead, as returned by the leads module.
///
/// The backend scopes visibility by role, so a lawyer only ever sees leads
/// assigned to them (or unassigned ones their role may claim).
class Lead {
  final int id;
  final String? reference;
  final String subject;
  final String status;
  final String priority;
  final String? source;
  final String? contactName;
  final String? contactPhone;
  final double? estimatedValue;
  final String currency;
  final String? followUpAt;
  final String? convertedAt;
  final int? convertedCaseId;
  final String createdAt;
  final String? specializationName;
  final String? assignedLawyerName;

  Lead({
    required this.id,
    this.reference,
    required this.subject,
    required this.status,
    required this.priority,
    this.source,
    this.contactName,
    this.contactPhone,
    this.estimatedValue,
    required this.currency,
    this.followUpAt,
    this.convertedAt,
    this.convertedCaseId,
    required this.createdAt,
    this.specializationName,
    this.assignedLawyerName,
  });

  bool get isOpen => !['converted', 'lost', 'closed'].contains(status);
  bool get isConverted => status == 'converted' || convertedCaseId != null;

  factory Lead.fromJson(Map<String, dynamic> json) => Lead(
        id: int.parse(json['id'].toString()),
        reference: json['reference']?.toString(),
        subject: json['subject'] ?? '',
        status: json['status'] ?? 'new',
        priority: json['priority'] ?? 'normal',
        source: json['source'],
        contactName: json['contact_name'],
        contactPhone: json['contact_phone'],
        estimatedValue: double.tryParse('${json['estimated_value']}'),
        currency: json['currency'] ?? 'BHD',
        followUpAt: json['follow_up_at'],
        convertedAt: json['converted_at'],
        convertedCaseId: int.tryParse('${json['converted_case_id']}'),
        createdAt: '${json['created_at']}',
        specializationName: json['specialization_name'],
        assignedLawyerName: json['assigned_lawyer_name'],
      );
}

class LeadActivity {
  final int id;
  final String activityType;
  final String? summary;
  final String? outcome;
  final String createdAt;
  final String? authorName;

  LeadActivity({
    required this.id,
    required this.activityType,
    this.summary,
    this.outcome,
    required this.createdAt,
    this.authorName,
  });

  factory LeadActivity.fromJson(Map<String, dynamic> json) => LeadActivity(
        id: int.parse(json['id'].toString()),
        activityType: json['activity_type'] ?? json['type'] ?? 'note',
        // The endpoint selects the column as `notes`; older rows may carry
        // `body`. Accept both so the trail renders either way.
        summary: json['notes'] ?? json['summary'] ?? json['body'] ?? json['note'],
        outcome: json['outcome'],
        createdAt: '${json['created_at']}',
        authorName: json['actor_name'] ?? json['author_name'],
      );
}
