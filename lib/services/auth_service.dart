import '../models/user.dart';
import 'api_client.dart';

/// Client authentication against the Lawyers.bh platform API.
///
/// These are the `/api/mobile/client-auth/*` routes on the main Next.js
/// deployment — the same ones the website uses. An account created on the
/// website can sign in here, and vice versa: both write to
/// `mobile_client_accounts` in the one production database.
///
/// Sign-in is **email + password**. Account creation and password reset use a
/// 6-digit code sent by email (`mode: register|reset`), not an SMS OTP.
class AuthService {
  final ApiClient api;
  AuthService(this.api);

  /// Email + password sign-in. Returns the bearer token and the client profile.
  Future<(String token, AppUser user)> login(String email, String password) async {
    final data = await api.post('/api/mobile/client-auth/login', {
      'email': email.trim().toLowerCase(),
      'password': password,
    });
    return (_tokenFrom(data), AppUser.fromJson(_clientFrom(data)));
  }

  /// Starts account creation (or a password reset) by emailing a 6-digit code.
  ///
  /// [mode] is `register` or `reset`. Registration also requires [fullName] and
  /// an international [phone] (`+` followed by 8–15 digits). Returns the
  /// challenge id to pass to [verify], and the resend cooldown in seconds.
  Future<(String challengeId, int retryAfterSeconds)> requestAccount({
    required String mode,
    required String email,
    required String password,
    String? fullName,
    String? phone,
    String locale = 'ar',
  }) async {
    final data = await api.post('/api/mobile/client-auth/request', {
      'mode': mode,
      'email': email.trim().toLowerCase(),
      'password': password,
      if (fullName != null && fullName.trim().isNotEmpty) 'fullName': fullName.trim(),
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      'locale': locale,
    });
    return (
      data['challengeId'] as String,
      int.tryParse('${data['retryAfterSeconds']}') ?? 60,
    );
  }

  /// Confirms the emailed code. On success the account is created/updated and a
  /// session token is returned.
  Future<(String token, AppUser user)> verify(String challengeId, String code) async {
    final data = await api.post('/api/mobile/client-auth/verify', {
      'challengeId': challengeId,
      'code': code,
    });
    return (_tokenFrom(data), AppUser.fromJson(_clientFrom(data)));
  }

  /// The signed-in client profile (`GET`, bearer token).
  Future<AppUser> session() async {
    final data = await api.get('/api/mobile/client-auth/session');
    return AppUser.fromJson(_clientFrom(data));
  }

  /// Ends the session server-side (`DELETE`, bearer token).
  Future<void> logout() => api.delete('/api/mobile/client-auth/session');

  /// Updates name and phone (`PATCH`, bearer token).
  Future<AppUser> updateProfile({required String fullName, required String phone}) async {
    final data = await api.patch('/api/mobile/client-auth/account', {
      'fullName': fullName.trim(),
      'phone': phone.trim(),
    });
    return AppUser.fromJson(_clientFrom(data));
  }

  /// Changes the password (`PATCH`, bearer token).
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      api.patch('/api/mobile/client-auth/password', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

  String _tokenFrom(Map<String, dynamic> data) {
    final token = data['token'];
    if (token is! String || token.isEmpty) {
      throw const ApiException('invalid_server_response', 200);
    }
    return token;
  }

  Map<String, dynamic> _clientFrom(Map<String, dynamic> data) {
    final client = data['client'];
    if (client is Map<String, dynamic>) return client;
    throw const ApiException('invalid_server_response', 200);
  }
}

