class CaseMilestone {
  final String label;
  final String state; // pending | active | done

  CaseMilestone({required this.label, required this.state});

  factory CaseMilestone.fromJson(Map<String, dynamic> json) => CaseMilestone(
        label: json['label'] ?? '',
        state: json['state'] ?? 'pending',
      );
}

class CaseDocument {
  final int id;
  final String title;
  final String filePath;

  CaseDocument({required this.id, required this.title, required this.filePath});

  factory CaseDocument.fromJson(Map<String, dynamic> json) => CaseDocument(
        id: int.parse(json['id'].toString()),
        title: json['title'] ?? '',
        filePath: json['file_path'] ?? '',
      );
}

class LegalCase {
  final int id;
  final String? uuid;
  final String? reference;
  final String? caseNumber;
  final String title;
  final String? caseType;
  final String status;
  final String priority;
  final String? courtName;
  final String? nextHearingAt;
  final int lawyerId;
  final String lawyerName;
  final String? clientName;
  final String? firmName;
  final double? agreedFee;
  final String currency;
  final int hearingsCount;
  final int openTasks;
  final String? openedAt;
  final List<CaseMilestone> timeline;
  final List<CaseDocument> documents;

  LegalCase({
    required this.id,
    this.uuid,
    this.reference,
    this.caseNumber,
    required this.title,
    this.caseType,
    required this.status,
    this.priority = 'normal',
    this.courtName,
    this.nextHearingAt,
    required this.lawyerId,
    required this.lawyerName,
    this.clientName,
    this.firmName,
    this.agreedFee,
    this.currency = 'BHD',
    this.hearingsCount = 0,
    this.openTasks = 0,
    this.openedAt,
    this.timeline = const [],
    this.documents = const [],
  });

  factory LegalCase.fromJson(Map<String, dynamic> json) => LegalCase(
        id: int.parse(json['id'].toString()),
        uuid: json['uuid']?.toString(),
        reference: json['reference']?.toString(),
        caseNumber: json['case_number']?.toString(),
        title: json['title'] ?? '',
        caseType: json['case_type'],
        status: json['status'] ?? 'received',
        priority: json['priority'] ?? 'normal',
        courtName: json['court_name'],
        nextHearingAt: json['next_hearing_at'],
        lawyerId: int.tryParse('${json['lawyer_id']}') ?? 0,
        lawyerName: json['lawyer_name'] ?? '',
        clientName: json['client_name'],
        firmName: json['firm_name'],
        agreedFee: double.tryParse('${json['agreed_fee']}'),
        currency: json['currency'] ?? 'BHD',
        hearingsCount: int.tryParse('${json['hearings_count']}') ?? 0,
        openTasks: int.tryParse('${json['open_tasks']}') ?? 0,
        openedAt: json['opened_at'],
        timeline: (json['timeline'] as List?)
                ?.map((e) => CaseMilestone.fromJson(e))
                .toList() ??
            const [],
        documents: (json['documents'] as List?)
                ?.map((e) => CaseDocument.fromJson(e))
                .toList() ??
            const [],
      );
}

/// A task inside a case workspace.
class CaseTask {
  final int id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final String? dueAt;
  final String? completedAt;
  final String? assignedToName;

  CaseTask({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueAt,
    this.completedAt,
    this.assignedToName,
  });

  bool get isDone => status == 'completed';

  factory CaseTask.fromJson(Map<String, dynamic> json) => CaseTask(
        id: int.parse(json['id'].toString()),
        title: json['title'] ?? '',
        description: json['description'],
        status: json['status'] ?? 'pending',
        priority: json['priority'] ?? 'normal',
        dueAt: json['due_at'],
        completedAt: json['completed_at'],
        assignedToName: json['assigned_to_name'],
      );
}

/// A court hearing on the case calendar.
class CaseHearing {
  final int id;
  final String hearingType;
  final String? scheduledAt;
  final int? durationMinutes;
  final String? courtName;
  final String? judgeName;
  final String? location;
  final String status;
  final String? outcome;
  final String? notes;

  CaseHearing({
    required this.id,
    required this.hearingType,
    this.scheduledAt,
    this.durationMinutes,
    this.courtName,
    this.judgeName,
    this.location,
    required this.status,
    this.outcome,
    this.notes,
  });

  factory CaseHearing.fromJson(Map<String, dynamic> json) => CaseHearing(
        id: int.parse(json['id'].toString()),
        hearingType: json['hearing_type'] ?? 'other',
        scheduledAt: json['scheduled_at'] ?? json['hearing_date'],
        durationMinutes: int.tryParse('${json['duration_minutes']}'),
        courtName: json['court_name'],
        judgeName: json['judge_name'],
        location: json['location'],
        status: json['status'] ?? 'scheduled',
        outcome: json['outcome'],
        notes: json['notes'],
      );
}

/// An internal or client-visible note on a case.
class CaseNote {
  final int id;
  final String visibility;
  final String body;
  final String? authorName;
  final String createdAt;

  CaseNote({
    required this.id,
    required this.visibility,
    required this.body,
    this.authorName,
    required this.createdAt,
  });

  bool get isInternal => visibility == 'internal';

  factory CaseNote.fromJson(Map<String, dynamic> json) => CaseNote(
        id: int.parse(json['id'].toString()),
        visibility: json['visibility'] ?? 'internal',
        body: json['body'] ?? '',
        authorName: json['author_name'],
        createdAt: '${json['created_at']}',
      );
}

/// A party to the case (opposing counsel, witness, expert...).
class CaseParty {
  final int id;
  final String partyType;
  final String name;
  final String? role;
  final String? phone;

  CaseParty({
    required this.id,
    required this.partyType,
    required this.name,
    this.role,
    this.phone,
  });

  factory CaseParty.fromJson(Map<String, dynamic> json) => CaseParty(
        id: int.parse(json['id'].toString()),
        partyType: json['party_type'] ?? json['party_role'] ?? 'other',
        name: json['name'] ?? json['full_name'] ?? '',
        role: json['role'],
        phone: json['phone'],
      );
}
