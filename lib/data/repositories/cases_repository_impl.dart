import 'package:lawyers_bh/data/datasources/remote/cases_remote_datasource.dart';
import 'package:lawyers_bh/domain/repositories/cases_repository.dart';
import 'package:lawyers_bh/domain/entities/case.dart';
import 'package:lawyers_bh/core/errors/exceptions.dart';

class CasesRepositoryImpl implements CasesRepository {
  final CasesRemoteDataSource _remoteDataSource;

  CasesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Case>> getCases({CaseStatus? status, int page = 1, int limit = 20}) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null) {
        query['status'] = status.name;
      }

      final response = await _remoteDataSource.getCases(query: query);
      return response.data.map((e) => e.toEntity()).toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<Case> getCaseDetails(String id) async {
    try {
      final model = await _remoteDataSource.getCaseDetails(id);
      return model.toEntity();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<Case> createCase({
    required String title,
    required String description,
    required String lawyerId,
  }) async {
    try {
      final model = await _remoteDataSource.createCase(
        CreateCaseRequestModel(
          title: title,
          description: description,
          lawyerId: lawyerId,
        ),
      );
      return model.toEntity();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> updateCaseStatus(String id, CaseStatus status) async {
    try {
      await _remoteDataSource.updateCaseStatus(id, status.name);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> addDocument(String caseId, CaseDocument document) async {
    try {
      await _remoteDataSource.addDocument(
        caseId,
        AddDocumentRequestModel(
          name: document.name,
          url: document.url,
          type: document.type,
          size: document.size,
        ),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> deleteDocument(String caseId, String documentId) async {
    try {
      await _remoteDataSource.deleteDocument(caseId, documentId);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }
}