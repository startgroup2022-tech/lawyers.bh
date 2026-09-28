import 'api_client.dart';

/// A payment intent as the backend models it.
class Payment {
  final int id;
  final String? paymentNumber;
  final String status;
  final double amount;
  final String currency;
  final String method;
  final String? gatewayReference;

  Payment({
    required this.id,
    this.paymentNumber,
    required this.status,
    required this.amount,
    required this.currency,
    required this.method,
    this.gatewayReference,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: int.parse((json['payment_id'] ?? json['id']).toString()),
        paymentNumber: json['payment_number']?.toString(),
        status: json['status'] ?? 'pending',
        amount: double.tryParse('${json['amount']}') ?? 0,
        currency: json['currency'] ?? 'BHD',
        method: json['method'] ?? 'benefitpay',
        gatewayReference: json['gateway_reference']?.toString(),
      );

  bool get isPaid => status == 'paid';
}

/// Parameters the mobile SDK needs to present the gateway's payment sheet.
class PaymentInitiation {
  final int paymentId;
  final double amount;
  final String currency;
  final String provider;
  final String method;

  PaymentInitiation({
    required this.paymentId,
    required this.amount,
    required this.currency,
    required this.provider,
    required this.method,
  });

  factory PaymentInitiation.fromJson(Map<String, dynamic> json) => PaymentInitiation(
        paymentId: int.parse((json['payment_id'] ?? json['id']).toString()),
        amount: double.tryParse('${json['amount']}') ?? 0,
        currency: json['currency'] ?? 'BHD',
        provider: json['provider'] ?? '',
        method: json['method'] ?? '',
      );
}

/// Talks to the canonical payment API.
///
/// The gateway itself is never driven from here: the app opens the gateway's
/// own SDK, then hands the resulting reference back to the server, which asks
/// the gateway what actually happened. The app cannot mark a payment as paid.
class PaymentsService {
  final ApiClient api;
  PaymentsService(this.api);

  /// Creates a payment intent for a signed contract.
  Future<Payment> create({
    required int contractId,
    required String method,
    String? idempotencyKey,
  }) async {
    final data = await api.post('/api/v1/payments', {
      'contract_id': contractId,
      'method': method,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
    });
    return Payment.fromJson(data);
  }

  /// Marks the intent as sent to the gateway and returns the SDK parameters.
  Future<PaymentInitiation> initiate(int paymentId) async {
    final data = await api.post('/api/v1/payments/$paymentId/initiate');
    return PaymentInitiation.fromJson(data);
  }

  /// Submits the gateway reference for server-side verification.
  ///
  /// Throws [ApiException] with code `gateway_not_configured` when the backend
  /// has no gateway credentials. That is a configuration problem, not a
  /// payment failure, and the caller should surface it as such.
  Future<Payment> confirm(int paymentId, {required String gatewayReference}) async {
    final data = await api.post(
      '/api/v1/payments/$paymentId/confirm',
      {'gateway_reference': gatewayReference},
    );
    return Payment.fromJson(data);
  }

  Future<Payment> show(int paymentId) async {
    final data = await api.get('/api/v1/payments/$paymentId');
    return Payment.fromJson(data['payment'] ?? data);
  }

  Future<List<Payment>> myPayments() async {
    final data = await api.get('/api/v1/payments');
    return (data['payments'] as List).map((e) => Payment.fromJson(e)).toList();
  }
}
