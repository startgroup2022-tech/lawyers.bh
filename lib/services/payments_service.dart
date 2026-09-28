import 'api_client.dart';

/// A payment intent as the platform models it.
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
}

/// Payments are attached to a booking or an emergency request, neither of which
/// the client app can create yet.
///
/// The mobile API exposes Tap gateway sessions (`/api/mobile/tap/*`) that are
/// opened from a website-created request, plus discount quotes
/// (`/api/mobile/discounts/quote`). There is no client-facing
/// "pay for my contract" endpoint because there is no client-facing contract.
/// These methods report the gap instead of posting to a route that does not
/// exist.
class PaymentsService {
  final ApiClient api;
  PaymentsService(this.api);

  static ApiException _unavailable() => ApiException.featureUnavailable(
        'الدفع غير متاح في التطبيق حاليًا',
      );

  Future<Payment> create({
    required int contractId,
    required String method,
    String? idempotencyKey,
  }) async =>
      throw _unavailable();

  Future<PaymentInitiation> initiate(int paymentId) async => throw _unavailable();

  Future<Payment> confirm(int paymentId, {required String gatewayReference}) async =>
      throw _unavailable();

  Future<Payment> show(int paymentId) async => throw _unavailable();

  Future<List<Payment>> myPayments() async => throw _unavailable();
}
