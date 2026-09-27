import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lawyers_bh/domain/entities/case.dart';

part 'case_models.freezed.dart';
part 'case_models.g.dart';

@freezed
class CaseModel with _$CaseModel {
  const factory CaseModel({
    required String id,
    required String title,
    required String description,
    required String clientId,
    required String lawyerId,
    required String lawyerName,
    required String status,
    required List<CaseTimelineEventModel> timeline,
    required List<CaseDocumentModel> documents,
    required String createdAt,
    String? updatedAt,
    String? completedAt,
  }) = _CaseModel;

  factory CaseModel.fromJson(Map<String, dynamic> json) => _$CaseModelFromJson(json);

  Case toEntity() {
    return Case(
      id: id,
      title: title,
      description: description,
      clientId: clientId,
      lawyerId: lawyerId,
      lawyerName: lawyerName,
      status: CaseStatus.values.byName(status),
      timeline: timeline.map((e) => e.toEntity()).toList(),
      documents: documents.map((e) => e.toEntity()).toList(),
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
      completedAt: completedAt != null ? DateTime.parse(completedAt!) : null,
    );
  }
}

@freezed
class CaseTimelineEventModel with _$CaseTimelineEventModel {
  const factory CaseTimelineEventModel({
    required String id,
    required String label,
    required String step,
    required String status,
    String? completedAt,
    String? notes,
  }) = _CaseTimelineEventModel;

  factory CaseTimelineEventModel.fromJson(Map<String, dynamic> json) => _$CaseTimelineEventModelFromJson(json);

  CaseTimelineEvent toEntity() {
    return CaseTimelineEvent(
      id: id,
      label: label,
      step: CaseStep.values.byName(step),
      status: TimelineStatus.values.byName(status),
      completedAt: completedAt != null ? DateTime.parse(completedAt!) : null,
      notes: notes,
    );
  }
}

@freezed
class CaseDocumentModel with _$CaseDocumentModel {
  const factory CaseDocumentModel({
    required String id,
    required String name,
    required String url,
    required String type,
    required int size,
    required String uploadedAt,
    required String uploadedBy,
  }) = _CaseDocumentModel;

  factory CaseDocumentModel.fromJson(Map<String, dynamic> json) => _$CaseDocumentModelFromJson(json);

  CaseDocument toEntity() {
    return CaseDocument(
      id: id,
      name: name,
      url: url,
      type: type,
      size: size,
      uploadedAt: DateTime.parse(uploadedAt),
      uploadedBy: uploadedBy,
    );
  }
}

@freezed
class CasesListResponseModel with _$CasesListResponseModel {
  const factory CasesListResponseModel({
    required List<CaseModel> data,
    required int total,
    required int page,
    required int limit,
    required int totalPages,
  }) = _CasesListResponseModel;

  factory CasesListResponseModel.fromJson(Map<String, dynamic> json) => _$CasesListResponseModelFromJson(json);
}

@freezed
class CreateCaseRequestModel with _$CreateCaseRequestModel {
  const factory CreateCaseRequestModel({
    required String title,
    required String description,
    required String lawyerId,
  }) = _CreateCaseRequestModel;

  factory CreateCaseRequestModel.fromJson(Map<String, dynamic> json) => _$CreateCaseRequestModelFromJson(json);
}

@freezed
class AddDocumentRequestModel with _$AddDocumentRequestModel {
  const factory AddDocumentRequestModel({
    required String name,
    required String url,
    required String type,
    required int size,
  }) = _AddDocumentRequestModel;

  factory AddDocumentRequestModel.fromJson(Map<String, dynamic> json) => _$AddDocumentRequestModelFromJson(json);
}