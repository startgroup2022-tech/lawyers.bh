import 'package:equatable/equatable.dart';

enum PaymentStatus { pending, processing, completed, failed, refunded, partial }
enum PaymentMethod { benefitPay, applePay, bankTransfer, cash, card }

class Payment extends Equatable {
  final String id;
  final String contractId;
  final String clientId;
  final String lawyerId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final PaymentMethod method;
  final String? reference;
  final String? transactionId;
  final String? gatewayResponse;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata;

  const Payment({
    required this.id,
    required this.contractId,
    required this.clientId,
    required this.lawyerId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.method,
    this.reference,
    this.transactionId,
    this.gatewayResponse,
    required this.createdAt,
    this.completedAt,
    this.metadata,
  });

  bool get isCompleted => status == PaymentStatus.completed;
  bool get isPending => status == PaymentStatus.pending || status == PaymentStatus.processing;
  bool get isFailed => status == PaymentStatus.failed;

  String get formattedAmount => '$amount $currency';

  @override
  List<Object?> get props => [
    id, contractId, clientId, lawyerId, amount, currency, status, method,
    reference, transactionId, gatewayResponse, createdAt, completedAt, metadata,
  ];
}