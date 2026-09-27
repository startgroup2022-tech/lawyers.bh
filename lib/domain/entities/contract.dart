import 'package:equatable/equatable.dart';

enum ContractStatus { draft, pendingSignature, active, completed, cancelled, expired }
enum ContractType { representation, feeAgreement, consultation, nda, powerOfAttorney }

class Contract extends Equatable {
  final String id;
  final String title;
  final ContractType type;
  final ContractStatus status;
  final String clientId;
  final String lawyerId;
  final String lawyerName;
  final String clientName;
  final double amount;
  final String currency;
  final String? description;
  final String? documentUrl;
  final String? signedDocumentUrl;
  final DateTime createdAt;
  final DateTime? signedAt;
  final DateTime? expiresAt;
  final List<ContractSignature> signatures;

  const Contract({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.clientId,
    required this.lawyerId,
    required this.lawyerName,
    required this.clientName,
    required this.amount,
    required this.currency,
    this.description,
    this.documentUrl,
    this.signedDocumentUrl,
    required this.createdAt,
    this.signedAt,
    this.expiresAt,
    required this.signatures,
  });

  bool get isPendingSignature => status == ContractStatus.pendingSignature;
  bool get isActive => status == ContractStatus.active;
  bool get isCompleted => status == ContractStatus.completed;
  bool get canSign => isPendingSignature && !signatures.any((s) => s.signerId == clientId);

  String get formattedAmount => '$amount $currency';

  @override
  List<Object?> get props => [
    id, title, type, status, clientId, lawyerId, lawyerName, clientName,
    amount, currency, description, documentUrl, signedDocumentUrl,
    createdAt, signedAt, expiresAt, signatures,
  ];
}

class ContractSignature extends Equatable {
  final String id;
  final String contractId;
  final String signerId;
  final String signerName;
  final String signerRole;
  final String signatureData;
  final DateTime signedAt;
  final String? ipAddress;

  const ContractSignature({
    required this.id,
    required this.contractId,
    required this.signerId,
    required this.signerName,
    required this.signerRole,
    required this.signatureData,
    required this.signedAt,
    this.ipAddress,
  });

  @override
  List<Object?> get props => [id, contractId, signerId, signerName, signerRole, signatureData, signedAt, ipAddress];
}