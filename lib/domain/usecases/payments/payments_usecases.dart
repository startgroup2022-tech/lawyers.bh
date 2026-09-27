import 'package:lawyers_bh/domain/entities/payment.dart';
import 'package:lawyers_bh/domain/repositories/repositories.dart';

class ProcessPaymentUseCase {
  final PaymentsRepository _repository;

  ProcessPaymentUseCase(this._repository);

  Future<Payment> call({
    required String contractId,
    required PaymentMethod method,
    required double amount,
  }) {
    return _repository.processPayment(
      contractId: contractId,
      method: method,
      amount: amount,
    );
  }
}

class GetPaymentDetailsUseCase {
  final PaymentsRepository _repository;

  GetPaymentDetailsUseCase(this._repository);

  Future<Payment> call(String id) {
    return _repository.getPaymentDetails(id);
  }
}

class GetPaymentsUseCase {
  final PaymentsRepository _repository;

  GetPaymentsUseCase(this._repository);

  Future<List<Payment>> call({PaymentStatus? status, int page = 1, int limit = 20}) {
    return _repository.getPayments(status: status, page: page, limit: limit);
  }
}

class RefundPaymentUseCase {
  final PaymentsRepository _repository;

  RefundPaymentUseCase(this._repository);

  Future<void> call(String id) {
    return _repository.refundPayment(id);
  }
}