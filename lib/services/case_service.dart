import '../models/contract.dart';
import '../models/legal_case.dart';
import 'api_client.dart';

class CaseService {
  final ApiClient api;
  CaseService(this.api);

  /// Books a consultation with a lawyer. This is the "matchmaking result":
  /// the backend opens a case + a draft contract ready to be signed.
  Future<(int caseId, int contractId)> bookConsultation({
    required int lawyerId,
    required String consultType, // video | voice | inperson
    String? subject,
    String? notes,
  }) async {
    final data = await api.post('/api/v1/bookings', {
      'lawyer_id': lawyerId,
      'consult_type': consultType,
      if (subject != null) 'subject': subject,
      if (notes != null) 'notes': notes,
    });
    return (int.parse('${data['case_id']}'), int.parse('${data['contract_id']}'));
  }

  Future<LegalContract> contractDetail(int contractId) async {
    final data = await api.get('/api/v1/contracts/$contractId');
    return LegalContract.fromJson(data['contract']);
  }

  Future<List<LegalContract>> myContracts() async {
    final data = await api.get('/api/v1/contracts');
    return (data['contracts'] as List).map((e) => LegalContract.fromJson(e)).toList();
  }

  Future<void> signContract(int contractId, String signatureBase64) => api.post(
        '/api/v1/contracts/$contractId/sign',
        {'signature_type': 'drawn', 'signature_data': signatureBase64},
      );

  Future<List<LegalCase>> myCases() async {
    final data = await api.get('/api/v1/cases');
    return (data['cases'] as List).map((e) => LegalCase.fromJson(e)).toList();
  }

  Future<LegalCase> caseDetail(int caseId) async {
    final data = await api.get('/api/v1/cases/$caseId');
    return LegalCase.fromJson(data['case']);
  }

  // ---- Lawyer workspace: the case itself ----------------------------------

  /// Creates a case. A lawyer files it for a client; `clientId` is only
  /// accepted from staff roles.
  Future<int> createCase({
    required String title,
    required int lawyerId,
    String? description,
    String caseType = 'consultation',
    String priority = 'normal',
    int? specializationId,
    int? serviceId,
    String? courtName,
    String? opposingParty,
    double? agreedFee,
    int? clientId,
  }) async {
    final data = await api.post('/api/v1/cases', {
      'title': title,
      'lawyer_id': lawyerId,
      'case_type': caseType,
      'priority': priority,
      if (description != null) 'description': description,
      if (specializationId != null) 'specialization_id': specializationId,
      if (serviceId != null) 'service_id': serviceId,
      if (courtName != null) 'court_name': courtName,
      if (opposingParty != null) 'opposing_party': opposingParty,
      if (agreedFee != null) 'agreed_fee': agreedFee,
      if (clientId != null) 'client_id': clientId,
    });
    return int.parse('${data['id']}');
  }

  Future<void> updateCase(int caseId, Map<String, dynamic> fields) =>
      api.patch('/api/v1/cases/$caseId', fields);

  Future<void> closeCase(int caseId, {String? reason}) => api.post(
        '/api/v1/cases/$caseId/close',
        {if (reason != null && reason.isNotEmpty) 'reason': reason},
      );

  Future<List<CaseTask>> tasks(int caseId) async {
    final data = await api.get('/api/v1/cases/$caseId/tasks');
    return (data['tasks'] as List).map((e) => CaseTask.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<int> addTask(
    int caseId, {
    required String title,
    String? description,
    String priority = 'normal',
    String? dueAt,
    int? assignedTo,
  }) async {
    final data = await api.post('/api/v1/cases/$caseId/tasks', {
      'title': title,
      'priority': priority,
      if (description != null) 'description': description,
      if (dueAt != null) 'due_at': dueAt,
      if (assignedTo != null) 'assigned_to': assignedTo,
    });
    return int.parse('${data['id']}');
  }

  Future<void> updateTask(int caseId, int taskId, Map<String, dynamic> fields) =>
      api.patch('/api/v1/cases/$caseId/tasks/$taskId', fields);

  Future<List<CaseHearing>> hearings(int caseId) async {
    final data = await api.get('/api/v1/cases/$caseId/hearings');
    return (data['hearings'] as List)
        .map((e) => CaseHearing.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> addHearing(
    int caseId, {
    required String date,
    String? time,
    String hearingType = 'other',
    String? courtName,
    String? judgeName,
    String? location,
    String? notes,
  }) async {
    final data = await api.post('/api/v1/cases/$caseId/hearings', {
      'hearing_date': date,
      'hearing_type': hearingType,
      if (time != null) 'hearing_time': time,
      if (courtName != null) 'court_name': courtName,
      if (judgeName != null) 'judge_name': judgeName,
      if (location != null) 'location': location,
      if (notes != null) 'notes': notes,
    });
    return int.parse('${data['id']}');
  }

  Future<void> updateHearing(int caseId, int hearingId, Map<String, dynamic> fields) =>
      api.patch('/api/v1/cases/$caseId/hearings/$hearingId', fields);

  Future<List<CaseNote>> notes(int caseId) async {
    final data = await api.get('/api/v1/cases/$caseId/notes');
    return (data['notes'] as List).map((e) => CaseNote.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<int> addNote(int caseId, {required String body, String visibility = 'internal'}) async {
    final data = await api.post('/api/v1/cases/$caseId/notes', {
      'body': body,
      'visibility': visibility,
    });
    return int.parse('${data['id']}');
  }

  Future<void> deleteNote(int caseId, int noteId) =>
      api.delete('/api/v1/cases/$caseId/notes/$noteId');

  Future<List<CaseParty>> parties(int caseId) async {
    final data = await api.get('/api/v1/cases/$caseId/parties');
    return (data['parties'] as List).map((e) => CaseParty.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<int> addParty(
    int caseId, {
    required String name,
    required String partyType,
    String? role,
    String? phone,
  }) async {
    final data = await api.post('/api/v1/cases/$caseId/parties', {
      'name': name,
      'party_type': partyType,
      if (role != null) 'role': role,
      if (phone != null) 'phone': phone,
    });
    return int.parse('${data['id']}');
  }
}

