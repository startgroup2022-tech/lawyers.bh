import 'package:lawyers_bh/core/network/api_client.dart';
import 'package:lawyers_bh/data/models/payment_models.dart';

abstract class PaymentsRemoteDataSource {
  Future<PaymentModel> processPayment(ProcessPaymentRequestModel request);
  Future<PaymentModel> getPaymentDetails(String id);
  Future<PaymentsListResponseModel> getPayments({Map<String, dynamic>? query});
  Future<void> refundPayment(String id);
}

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  final ApiClient _apiClient;

  PaymentsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<PaymentModel> processPayment(ProcessPaymentRequestModel request) async {
    final response = await _apiClient.post('/payments', data: request.toJson());
    return PaymentModel.fromJson(response.data);
  }

  @override
  Future<PaymentModel> getPaymentDetails(String id) async {
    final response = await _apiClient.get('/payments/$id');
    return PaymentModel.fromJson(response.data);
  }

  @override
  Future<PaymentsListResponseModel> getPayments({Map<String, dynamic>? query}) async {
    final response = await _apiClient.get('/payments', queryParameters: query);
    return PaymentsListResponseModel.fromJson(response.data);
  }

  @override
  Future<void> refundPayment(String id) async {
    await _apiClient.post('/payments/$id/refund');
  }
}