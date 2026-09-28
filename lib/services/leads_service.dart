import '../models/lead.dart';
import 'api_client.dart';

/// The Legal CRM lead pipeline is a web-portal capability, not a mobile one.
///
/// The platform exposes no `/leads` routes to a client or to the mobile lawyer
/// session; lead management lives in the lawyer/admin web portal. These methods
/// report the gap instead of returning an empty pipeline.
class LeadsService {
  final ApiClient api;
  LeadsService(this.api);

  static ApiException _unavailable() => ApiException.featureUnavailable(
        'إدارة العملاء المحتملين غير متاحة في التطبيق حاليًا',
      );

  Future<List<Lead>> list({String? status, String? priority}) async =>
      throw _unavailable();

  Future<(Lead lead, List<LeadActivity> activities)> detail(int id) async =>
      throw _unavailable();

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
  }) async =>
      throw _unavailable();

  Future<void> update(
    int id, {
    String? status,
    String? priority,
    String? nextAction,
    double? estimatedValue,
    String? lostReason,
    int? assignedLawyerId,
  }) async =>
      throw _unavailable();

  Future<int> addActivity(int id, {required String type, required String notes}) async =>
      throw _unavailable();

  Future<int> convert(int id, {String? caseType, String? priority, String? title}) async =>
      throw _unavailable();
}
