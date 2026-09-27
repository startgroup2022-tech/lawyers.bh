import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawyers_bh/domain/usecases/cases/get_cases_usecase.dart';
import 'package:lawyers_bh/domain/usecases/cases/get_case_details_usecase.dart';
import 'package:lawyers_bh/domain/usecases/cases/create_case_usecase.dart';
import 'package:lawyers_bh/domain/usecases/cases/update_case_status_usecase.dart';
import 'package:lawyers_bh/domain/usecases/cases/add_case_document_usecase.dart';
import 'package:lawyers_bh/domain/usecases/cases/delete_case_document_usecase.dart';
import 'package:lawyers_bh/domain/entities/case.dart';
import 'package:lawyers_bh/core/errors/exceptions.dart';

class CasesState {
  final List<Case> cases;
  final Case? selectedCase;
  final bool isLoading;
  final String? error;

  const CasesState({
    this.cases = const [],
    this.selectedCase,
    this.isLoading = false,
    this.error,
  });

  CasesState copyWith({
    List<Case>? cases,
    Case? selectedCase,
    bool? isLoading,
    String? error,
  }) {
    return CasesState(
      cases: cases ?? this.cases,
      selectedCase: selectedCase ?? this.selectedCase,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CasesProvider extends StateNotifier<CasesState> {
  final GetCasesUseCase _getCasesUseCase;
  final GetCaseDetailsUseCase _getCaseDetailsUseCase;
  final CreateCaseUseCase _createCaseUseCase;
  final UpdateCaseStatusUseCase _updateCaseStatusUseCase;
  final AddCaseDocumentUseCase _addCaseDocumentUseCase;
  final DeleteCaseDocumentUseCase _deleteCaseDocumentUseCase;

  CasesProvider({
    required GetCasesUseCase getCasesUseCase,
    required GetCaseDetailsUseCase getCaseDetailsUseCase,
    required CreateCaseUseCase createCaseUseCase,
    required UpdateCaseStatusUseCase updateCaseStatusUseCase,
    required AddCaseDocumentUseCase addCaseDocumentUseCase,
    required DeleteCaseDocumentUseCase deleteCaseDocumentUseCase,
  })  : _getCasesUseCase = getCasesUseCase,
        _getCaseDetailsUseCase = getCaseDetailsUseCase,
        _createCaseUseCase = createCaseUseCase,
        _updateCaseStatusUseCase = updateCaseStatusUseCase,
        _addCaseDocumentUseCase = addCaseDocumentUseCase,
        _deleteCaseDocumentUseCase = deleteCaseDocumentUseCase,
        super(const CasesState());

  Future<void> loadCases({CaseStatus? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final cases = await _getCasesUseCase(status: status);
      state = state.copyWith(cases: cases, isLoading: false);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'حدث خطأ غير متوقع');
    }
  }

  Future<void> loadCaseDetails(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final case_ = await _getCaseDetailsUseCase(id);
      state = state.copyWith(selectedCase: case_, isLoading: false);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'حدث خطأ غير متوقع');
    }
  }

  Future<Case> createCase({
    required String title,
    required String description,
    required String lawyerId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final case_ = await _createCaseUseCase(
        title: title,
        description: description,
        lawyerId: lawyerId,
      );
      state = state.copyWith(cases: [case_, ...state.cases], isLoading: false);
      return case_;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'حدث خطأ غير متوقع');
      rethrow;
    }
  }

  Future<void> updateCaseStatus(String id, CaseStatus status) async {
    try {
      await _updateCaseStatusUseCase(id, status);
      final updatedCases = state.cases.map((c) {
        if (c.id == id) {
          return c.copyWith(status: status);
        }
        return c;
      }).toList();
      state = state.copyWith(cases: updatedCases);
      if (state.selectedCase?.id == id) {
        state = state.copyWith(selectedCase: state.selectedCase!.copyWith(status: status));
      }
    } catch (_) {}
  }

  Future<void> addDocument(String caseId, CaseDocument document) async {
    try {
      await _addCaseDocumentUseCase(caseId, document);
      if (state.selectedCase?.id == caseId) {
        final updatedDocs = [...state.selectedCase!.documents, document];
        state = state.copyWith(
          selectedCase: state.selectedCase!.copyWith(documents: updatedDocs),
        );
      }
    } catch (_) {}
  }

  Future<void> deleteDocument(String caseId, String documentId) async {
    try {
      await _deleteCaseDocumentUseCase(caseId, documentId);
      if (state.selectedCase?.id == caseId) {
        final updatedDocs = state.selectedCase!.documents
            .where((d) => d.id != documentId)
            .toList();
        state = state.copyWith(
          selectedCase: state.selectedCase!.copyWith(documents: updatedDocs),
        );
      }
    } catch (_) {}
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}