import 'package:lawyers_bh/domain/entities/case.dart';
import 'package:lawyers_bh/domain/repositories/repositories.dart';

class GetCasesUseCase {
  final CasesRepository _repository;

  GetCasesUseCase(this._repository);

  Future<List<Case>> call({CaseStatus? status, int page = 1, int limit = 20}) {
    return _repository.getCases(status: status, page: page, limit: limit);
  }
}

class GetCaseDetailsUseCase {
  final CasesRepository _repository;

  GetCaseDetailsUseCase(this._repository);

  Future<Case> call(String id) {
    return _repository.getCaseDetails(id);
  }
}

class CreateCaseUseCase {
  final CasesRepository _repository;

  CreateCaseUseCase(this._repository);

  Future<Case> call({
    required String title,
    required String description,
    required String lawyerId,
  }) {
    return _repository.createCase(
      title: title,
      description: description,
      lawyerId: lawyerId,
    );
  }
}

class UpdateCaseStatusUseCase {
  final CasesRepository _repository;

  UpdateCaseStatusUseCase(this._repository);

  Future<void> call(String id, CaseStatus status) {
    return _repository.updateCaseStatus(id, status);
  }
}

class AddCaseDocumentUseCase {
  final CasesRepository _repository;

  AddCaseDocumentUseCase(this._repository);

  Future<void> call(String caseId, CaseDocument document) {
    return _repository.addDocument(caseId, document);
  }
}

class DeleteCaseDocumentUseCase {
  final CasesRepository _repository;

  DeleteCaseDocumentUseCase(this._repository);

  Future<void> call(String caseId, String documentId) {
    return _repository.deleteDocument(caseId, documentId);
  }
}