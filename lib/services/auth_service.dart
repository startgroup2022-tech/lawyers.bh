import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient api;
  AuthService(this.api);

  /// Requests a login OTP. The backend creates the account on first verify.
  Future<void> sendOtp(String phone) =>
      api.post('/api/v1/auth/otp/request', {'phone': phone});

  Future<(String token, AppUser user)> verifyOtp(String phone, String code) async {
    final data = await api.post('/api/v1/auth/otp/verify', {'phone': phone, 'code': code});
    final token = data['token'] as String;
    final user = AppUser.fromJson(data['user']);
    return (token, user);
  }

  Future<AppUser> me() async {
    final data = await api.get('/api/v1/auth/me');
    return AppUser.fromJson(data['user']);
  }

  Future<void> logout() => api.post('/api/v1/auth/logout');
}

