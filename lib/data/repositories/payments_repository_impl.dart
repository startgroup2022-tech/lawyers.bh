import 'package:lawyers_bh/data/datasources/remote/payments_remote_datasource.dart';
import 'package:lawyers_bh/domain/repositories/payments_repository.dart';
import 'package:lawyers_bh/domain/entities/payment.dart';
import 'package:lawyers_bh/core/errors/exceptions.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  final PaymentsRemoteDataSource _remoteDataSource;

  PaymentsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Payment> processPayment({
    required String contractId,
    required PaymentMethod method,
    required double amount,
  }) async {
    try {
      final model = await _remoteDataSource.processPayment(
        ProcessPaymentRequestModel(
          contractId: contractId,
          method: method.name,
          amount: amount,
        ),
      );
      return model.toEntity();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<Payment> getPaymentDetails(String id) async {
    try {
      final model = await _remoteDataSource.getPaymentDetails(id);
      return model.toEntity();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<List<Payment>> getPayments({PaymentStatus? status, int page = 1, int limit = 20}) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null) {
        query['status'] = status.name;
      }

      final response = await _remoteDataSource.getPayments(query: query);
      return response.data.map((e) => e.toEntity()).toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> refundPayment(String id) async {
    try {
      await _remoteDataSource.refundPayment(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }
}