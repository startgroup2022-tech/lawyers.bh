import 'api_client.dart';

/// Emergency (SOS) requests are created through the platform's emergency flow,
/// which is driven by the website and the dispatch system.
///
/// The mobile API exposes the *lawyer/dispatch* side of SOS (candidate
/// decisions, request status, push) but there is no client-facing
/// "create an emergency request" route on this deployment. The client SOS
/// button therefore cannot be wired to a real endpoint yet; it reports the gap
/// instead of posting to a route that does not exist.
class SosService {
  final ApiClient api;
  SosService(this.api);

  static ApiException _unavailable() => ApiException.featureUnavailable(
        'طلب النجدة غير متاح في التطبيق حاليًا',
      );

  Future<void> trigger({double? latitude, double? longitude, String? note}) async =>
      throw _unavailable();
}
