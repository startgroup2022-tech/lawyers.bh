import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lawyers_bh/domain/entities/payment.dart';

part 'payment_models.freezed.dart';
part 'payment_models.g.dart';

@freezed
class PaymentModel with _$PaymentModel {
  const factory PaymentModel({
    required String id,
    required String contractId,
    required String clientId,
    required String lawyerId,
    required double amount,
    required String currency,
    required String status,
    required String method,
    String? reference,
    String? transactionId,
    String? gatewayResponse,
    required String createdAt,
    String? completedAt,
    Map<String, dynamic>? metadata,
  }) = _PaymentModel;

  factory PaymentModel.fromJson(Map<String, dynamic> json) => _$PaymentModelFromJson(json);

  Payment toEntity() {
    return Payment(
      id: id,
      contractId: contractId,
      clientId: clientId,
      lawyerId: lawyerId,
      amount: amount,
      currency: currency,
      status: PaymentStatus.values.byName(status),
      method: PaymentMethod.values.byName(method),
      reference: reference,
      transactionId: transactionId,
      gatewayResponse: gatewayResponse,
      createdAt: DateTime.parse(createdAt),
      completedAt: completedAt != null ? DateTime.parse(completedAt!) : null,
      metadata: metadata,
    );
  }
}

@freezed
class PaymentsListResponseModel with _$PaymentsListResponseModel {
  const factory PaymentsListResponseModel({
    required List<PaymentModel> data,
    required int total,
    required int page,
    required int limit,
    required int totalPages,
  }) = _PaymentsListResponseModel;

  factory PaymentsListResponseModel.fromJson(Map<String, dynamic> json) => _$PaymentsListResponseModelFromJson(json);
}

@freezed
class ProcessPaymentRequestModel with _$ProcessPaymentRequestModel {
  const factory ProcessPaymentRequestModel({
    required String contractId,
    required String method,
    required double amount,
  }) = _ProcessPaymentRequestModel;

  factory ProcessPaymentRequestModel.fromJson(Map<String, dynamic> json) => _$ProcessPaymentRequestModelFromJson(json);
}