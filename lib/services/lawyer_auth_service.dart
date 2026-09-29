import '../models/user.dart';
import 'api_client.dart';

/// Lawyer authentication against the Lawyers.bh platform API.
///
/// This is a **separate sign-in door** from the client one. A lawyer is a
/// `bahrain_lawyers` record and signs in with their licence (registration)
/// number and password via `POST /api/lawyers/login`; the response carries a
/// signed mobile lawyer session token. A client is a `mobile_client_accounts`
/// record and signs in with email + password through `/api/mobile/client-auth/*`.
/// The two are disjoint — the same email can exist as both — and the tokens are
/// not interchangeable.
///
/// The lawyer token is a stateless signed value (30-day TTL). There is no
/// server-side logout route for it; access is revoked by closing the account,
/// which the API checks on every request.
class LawyerAuthService {
  final ApiClient api;
  LawyerAuthService(this.api);

  /// Licence number + password sign-in.
  ///
  /// Returns the bearer token and the lawyer's identity. The login response
  /// carries only id/phone/status, so the profile is completed from
  /// `GET /api/mobile/lawyer/session`, which is where the name comes from.
  Future<(String token, AppUser user)> login({
    required String licenseNumber,
    required String password,
    String countryCode = 'BH',
  }) async {
    final data = await api.post('/api/lawyers/login', {
      'licenseNumber': licenseNumber.trim(),
      'password': password,
      'countryCode': countryCode,
    });

    final token = data['token'];
    if (token is! String || token.isEmpty) {
      throw const ApiException('invalid_server_response', 200);
    }

    // The session call needs the token, so set it before asking for the
    // profile; clear it again if that call fails, so a half-finished login
    // never leaves a token behind on a logged-out app.
    api.setToken(token);
    try {
      return (token, await session());
    } catch (_) {
      api.setToken(null);
      rethrow;
    }
  }

  /// The signed-in lawyer's own account summary (`GET /api/mobile/lawyer/session`).
  Future<AppUser> session() async {
    final data = await api.get('/api/mobile/lawyer/session');
    final lawyer = data['lawyer'];
    if (lawyer is! Map<String, dynamic>) {
      throw const ApiException('invalid_server_response', 200);
    }
    return AppUser(
      id: lawyer['id']?.toString() ?? '',
      phone: lawyer['phone']?.toString() ?? '',
      name: (lawyer['nameAr'] ?? lawyer['nameEn'])?.toString(),
      role: AppRoles.lawyer,
      kind: AccountKind.lawyer,
      email: lawyer['email']?.toString(),
      isVerified: lawyer['status'] == 'approved',
    );
  }
}
