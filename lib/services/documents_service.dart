import 'api_client.dart';

/// A document as listed by `GET /documents`. The backend already filters by
/// what the caller may see, so no client-side visibility logic is needed.
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

  factory CaseDoc.fromJson(Map<String, dynamic> json) => CaseDoc(
        id: int.parse(json['id'].toString()),
        title: json['title'] ?? '',
        description: json['description'],
        scope: json['scope'] ?? 'general',
        visibility: json['visibility'] ?? 'internal',
        status: json['status'] ?? 'active',
        caseId: int.tryParse('${json['case_id']}'),
        currentVersion: int.tryParse('${json['current_version']}') ?? 1,
        versionsCount: int.tryParse('${json['versions_count']}') ?? 1,
        categoryName: json['category_name'],
        currentFilename: json['current_filename'],
        currentSize: int.tryParse('${json['current_size']}'),
        updatedAt: '${json['updated_at']}',
      );
}

class DocumentCategory {
  final int id;
  final String slug;
  final String nameAr;

  DocumentCategory({required this.id, required this.slug, required this.nameAr});

  factory DocumentCategory.fromJson(Map<String, dynamic> json) => DocumentCategory(
        id: int.parse(json['id'].toString()),
        slug: json['slug'] ?? '',
        nameAr: json['name_ar'] ?? '',
      );
}

/// The document vault. Uploads go through a multipart request; the rest is
/// plain JSON.
class DocumentsService {
  final ApiClient api;
  DocumentsService(this.api);

  Future<List<CaseDoc>> list({int? caseId, String? scope}) async {
    final data = await api.get('/api/v1/documents', query: {
      if (caseId != null) 'case_id': caseId,
      if (scope != null && scope.isNotEmpty) 'scope': scope,
    });
    return (data['documents'] as List)
        .map((e) => CaseDoc.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<DocumentCategory>> categories() async {
    final data = await api.get('/api/v1/document-categories');
    return (data['categories'] as List)
        .map((e) => DocumentCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Registers a document record. The binary upload is a separate step
  /// (`POST /documents/{id}/versions`), which needs a file picker and is left
  /// to the platform layer.
  Future<int> create({
    required String title,
    required String scope,
    String? description,
    String visibility = 'internal',
    int? caseId,
    int? categoryId,
  }) async {
    final data = await api.post('/api/v1/documents', {
      'title': title,
      'scope': scope,
      'visibility': visibility,
      if (description != null) 'description': description,
      if (caseId != null) 'case_id': caseId,
      if (categoryId != null) 'category_id': categoryId,
    });
    return int.parse('${data['id']}');
  }

  Future<void> delete(int id) => api.delete('/api/v1/documents/$id');
}
