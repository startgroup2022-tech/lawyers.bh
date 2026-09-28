import '../models/contract.dart';
import '../models/legal_case.dart';
import 'api_client.dart';

/// Booking, contracts and case management are not exposed by the platform's
/// mobile API.
///
/// The public platform has no `/bookings`, `/contracts` or `/cases` routes. A
/// consultation is requested through the website's own booking/emergency flow,
/// and the case workspace is the lawyer web portal. The screens that map to this
/// model report the gap explicitly rather than rendering a permanently empty
/// list as though the account simply had no cases.
class CaseService {
  final ApiClient api;
  CaseService(this.api);

  static ApiException _unavailable() => ApiException.featureUnavailable(
        'إدارة القضايا والعقود غير متاحة في تطبيق العميل حاليًا',
      );

  Future<(int caseId, int contractId)> bookConsultation({
    required int lawyerId,
    required String consultType,
    String? subject,
    String? notes,
  }) async =>
      throw _unavailable();

  Future<LegalContract> contractDetail(int contractId) async => throw _unavailable();

  Future<List<LegalContract>> myContracts() async => throw _unavailable();

  Future<void> signContract(int contractId, String signatureBase64) async =>
      throw _unavailable();

  Future<List<LegalCase>> myCases() async => throw _unavailable();

  Future<LegalCase> caseDetail(int caseId) async => throw _unavailable();

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
  }) async =>
      throw _unavailable();

  Future<void> updateCase(int caseId, Map<String, dynamic> fields) async =>
      throw _unavailable();

  Future<void> closeCase(int caseId, {String? reason}) async => throw _unavailable();

  Future<List<CaseTask>> tasks(int caseId) async => throw _unavailable();

  Future<int> addTask(
    int caseId, {
    required String title,
    String? description,
    String priority = 'normal',
    String? dueAt,
    int? assignedTo,
  }) async =>
      throw _unavailable();

  Future<void> updateTask(int caseId, int taskId, Map<String, dynamic> fields) async =>
      throw _unavailable();

  Future<List<CaseHearing>> hearings(int caseId) async => throw _unavailable();

  Future<int> addHearing(
    int caseId, {
    required String date,
    String? time,
    String hearingType = 'other',
    String? courtName,
    String? judgeName,
    String? location,
    String? notes,
  }) async =>
      throw _unavailable();

  Future<void> updateHearing(int caseId, int hearingId, Map<String, dynamic> fields) async =>
      throw _unavailable();

  Future<List<CaseNote>> notes(int caseId) async => throw _unavailable();

  Future<int> addNote(int caseId, {required String body, String visibility = 'internal'}) async =>
      throw _unavailable();

  Future<void> deleteNote(int caseId, int noteId) async => throw _unavailable();

  Future<List<CaseParty>> parties(int caseId) async => throw _unavailable();

  Future<int> addParty(
    int caseId, {
    required String name,
    required String partyType,
    String? role,
    String? phone,
  }) async =>
      throw _unavailable();
}
