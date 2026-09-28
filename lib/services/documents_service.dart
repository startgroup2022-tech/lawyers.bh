import 'api_client.dart';

/// A document as the document vault models it.
class CaseDoc {
  final int id;
  final String title;
  final String? description;
  final String scope;
  final String visibility;
  final String status;
  final int? caseId;
  final int currentVersion;
  final int versionsCount;
  final String? categoryName;
  final String? currentFilename;
  final int? currentSize;
  final String updatedAt;

  CaseDoc({
    required this.id,
    required this.title,
    this.description,
    required this.scope,
    required this.visibility,
    required this.status,
    this.caseId,
    required this.currentVersion,
    required this.versionsCount,
    this.categoryName,
    this.currentFilename,
    this.currentSize,
    required this.updatedAt,
  });
}

class DocumentCategory {
  final int id;
  final String slug;
  final String nameAr;

  DocumentCategory({required this.id, required this.slug, required this.nameAr});
}

/// The document vault is a web-portal capability, not a mobile one.
///
/// The platform exposes no `/documents` or `/document-categories` routes to the
/// mobile app; the vault lives in the lawyer/admin web portal. These methods
/// report the gap instead of returning an empty vault.
class DocumentsService {
  final ApiClient api;
  DocumentsService(this.api);

  static ApiException _unavailable() => ApiException.featureUnavailable(
        'خزنة المستندات غير متاحة في التطبيق حاليًا',
      );

  Future<List<CaseDoc>> list({int? caseId, String? scope}) async => throw _unavailable();

  Future<List<DocumentCategory>> categories() async => throw _unavailable();

  Future<int> create({
    required String title,
    required String scope,
    String? description,
    String visibility = 'internal',
    int? caseId,
    int? categoryId,
  }) async =>
      throw _unavailable();

  Future<void> delete(int id) async => throw _unavailable();
}
