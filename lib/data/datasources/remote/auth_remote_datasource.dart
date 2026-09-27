import 'package:lawyers_bh/core/network/api_client.dart';
import 'package:lawyers_bh/data/models/auth_models.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<AuthResponseModel> register(RegisterRequestModel request);
  Future<void> logout();
  Future<AuthResponseModel> refreshToken(String refreshToken);
  Future<void> forgotPassword(String phone);
  Future<void> verifyOtp(VerifyOtpRequestModel request);
  Future<UserModel> getCurrentUser();
  Future<UserModel> updateProfile(Map<String, dynamic> data);
  Future<void> changePassword(ChangePasswordRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: request.toJson(),
    );
    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: request.toJson(),
    );
    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<void> logout() async {
    await _apiClient.post('/auth/logout');
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    final response = await _apiClient.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<void> forgotPassword(String phone) async {
    await _apiClient.post('/auth/forgot-password', data: {'phone': phone});
  }

  @override
  Future<void> verifyOtp(VerifyOtpRequestModel request) async {
    await _apiClient.post('/auth/verify-otp', data: request.toJson());
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get('/auth/me');
    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiClient.patch('/auth/profile', data: data);
    return UserModel.fromJson(response.data);
  }

  @override
  Future<void> changePassword(ChangePasswordRequestModel request) async {
    await _apiClient.post('/auth/change-password', data: request.toJson());
  }
}