import 'package:lawyers_bh/core/network/api_client.dart';
import 'package:lawyers_bh/data/models/case_models.dart';

abstract class CasesRemoteDataSource {
  Future<CasesListResponseModel> getCases({Map<String, dynamic>? query});
  Future<CaseModel> getCaseDetails(String id);
  Future<CaseModel> createCase(CreateCaseRequestModel request);
  Future<void> updateCaseStatus(String id, String status);
  Future<void> addDocument(String caseId, AddDocumentRequestModel request);
  Future<void> deleteDocument(String caseId, String documentId);
}

class CasesRemoteDataSourceImpl implements CasesRemoteDataSource {
  final ApiClient _apiClient;

  CasesRemoteDataSourceImpl(this._apiClient);

  @override
  Future<CasesListResponseModel> getCases({Map<String, dynamic>? query}) async {
    final response = await _apiClient.get('/cases', queryParameters: query);
    return CasesListResponseModel.fromJson(response.data);
  }

  @override
  Future<CaseModel> getCaseDetails(String id) async {
    final response = await _apiClient.get('/cases/$id');
    return CaseModel.fromJson(response.data);
  }

  @override
  Future<CaseModel> createCase(CreateCaseRequestModel request) async {
    final response = await _apiClient.post('/cases', data: request.toJson());
    return CaseModel.fromJson(response.data);
  }

  @override
  Future<void> updateCaseStatus(String id, String status) async {
    await _apiClient.patch('/cases/$id/status', data: {'status': status});
  }

  @override
  Future<void> addDocument(String caseId, AddDocumentRequestModel request) async {
    await _apiClient.post('/cases/$caseId/documents', data: request.toJson());
  }

  @override
  Future<void> deleteDocument(String caseId, String documentId) async {
    await _apiClient.delete('/cases/$caseId/documents/$documentId');
  }
}