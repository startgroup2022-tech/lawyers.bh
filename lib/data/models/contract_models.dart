import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lawyers_bh/domain/entities/contract.dart';

part 'contract_models.freezed.dart';
part 'contract_models.g.dart';

@freezed
class ContractModel with _$ContractModel {
  const factory ContractModel({
    required String id,
    required String title,
    required String type,
    required String status,
    required String clientId,
    required String lawyerId,
    required String lawyerName,
    required String clientName,
    required double amount,
    required String currency,
    String? description,
    String? documentUrl,
    String? signedDocumentUrl,
    required String createdAt,
    String? signedAt,
    String? expiresAt,
    required List<ContractSignatureModel> signatures,
  }) = _ContractModel;

  factory ContractModel.fromJson(Map<String, dynamic> json) => _$ContractModelFromJson(json);

  Contract toEntity() {
    return Contract(
      id: id,
      title: title,
      type: ContractType.values.byName(type),
      status: ContractStatus.values.byName(status),
      clientId: clientId,
      lawyerId: lawyerId,
      lawyerName: lawyerName,
      clientName: clientName,
      amount: amount,
      currency: currency,
      description: description,
      documentUrl: documentUrl,
      signedDocumentUrl: signedDocumentUrl,
      createdAt: DateTime.parse(createdAt),
      signedAt: signedAt != null ? DateTime.parse(signedAt!) : null,
      expiresAt: expiresAt != null ? DateTime.parse(expiresAt!) : null,
      signatures: signatures.map((e) => e.toEntity()).toList(),
    );
  }
}

@freezed
class ContractSignatureModel with _$ContractSignatureModel {
  const factory ContractSignatureModel({
    required String id,
    required String contractId,
    required String signerId,
    required String signerName,
    required String signerRole,
    required String signatureData,
    required String signedAt,
    String? ipAddress,
  }) = _ContractSignatureModel;

  factory ContractSignatureModel.fromJson(Map<String, dynamic> json) => _$ContractSignatureModelFromJson(json);

  ContractSignature toEntity() {
    return ContractSignature(
      id: id,
      contractId: contractId,
      signerId: signerId,
      signerName: signerName,
      signerRole: signerRole,
      signatureData: signatureData,
      signedAt: DateTime.parse(signedAt),
      ipAddress: ipAddress,
    );
  }
}

@freezed
class ContractsListResponseModel with _$ContractsListResponseModel {
  const factory ContractsListResponseModel({
    required List<ContractModel> data,
    required int total,
    required int page,
    required int limit,
    required int totalPages,
  }) = _ContractsListResponseModel;

  factory ContractsListResponseModel.fromJson(Map<String, dynamic> json) => _$ContractsListResponseModelFromJson(json);
}

@freezed
class CreateContractRequestModel with _$CreateContractRequestModel {
  const factory CreateContractRequestModel({
    required String lawyerId,
    required String type,
    required double amount,
    String? description,
  }) = _CreateContractRequestModel;

  factory CreateContractRequestModel.fromJson(Map<String, dynamic> json) => _$CreateContractRequestModelFromJson(json);
}

@freezed
class SignContractRequestModel with _$SignContractRequestModel {
  const factory SignContractRequestModel({
    required String signatureData,
  }) = _SignContractRequestModel;

  factory SignContractRequestModel.fromJson(Map<String, dynamic> json) => _$SignContractRequestModelFromJson(json);
}