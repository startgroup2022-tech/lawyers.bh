import 'package:lawyers_bh/core/network/api_client.dart';
import 'package:lawyers_bh/data/models/auth_models.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<RegisterResponseModel> register(RegisterRequestModel request);
  Future<void> logout(String token);
  Future<AuthResponseModel> verifyOtp(VerifyOtpRequestModel request);
  Future<ForgotPasswordResponseModel> forgotPassword(ForgotPasswordRequestModel request);
  Future<VerifyOtpResponseModel> verifyForgotPasswordOtp(VerifyOtpRequestModel request);
  Future<SessionResponseModel> getSession(String token);
  Future<UpdateProfileResponseModel> updateProfile(String token, UpdateProfileRequestModel request);
  Future<void> changePassword(String token, ChangePasswordRequestModel request);
  Future<RegisterResponseModel> requestEmailChange(String token, RequestEmailChangeRequestModel request);
  Future<VerifyEmailChangeResponseModel> verifyEmailChange(String token, VerifyEmailChangeRequestModel request);
  Future<void> changePassword(String token, ChangePasswordRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    final response = await _apiClient.post(
      '/api/mobile/client-auth/login',
      data: request.toJson(),
    );
    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    final response = await _apiClient.post(
      '/api/mobile/client-auth/request',
      data: request.toJson(),
    );
    return RegisterResponseModel.fromJson(response.data);
  }

  @override
  Future<void> logout(String token) async {
    await _apiClient.post(
      '/api/mobile/client-auth/logout',
      data: {'token': token},
    );
  }

  @override
  Future<AuthResponseModel> verifyOtp(VerifyOtpRequestModel request) async {
    final response = await _apiClient.post(
      '/api/mobile/client-auth/verify',
      data: request.toJson(),
    );
    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<ForgotPasswordResponseModel> forgotPassword(ForgotPasswordRequestModel request) async {
    final response = await _apiClient.post(
      '/api/mobile/client-auth/password',
      data: request.toJson(),
    );
    return ForgotPasswordResponseModel.fromJson(response.data);
  }

  @override
  Future<VerifyOtpResponseModel> verifyForgotPasswordOtp(VerifyOtpRequestModel request) async {
    final response = await _apiClient.post(
      '/api/mobile/client-auth/password/verify',
      data: request.toJson(),
    );
    return VerifyOtpResponseModel.fromJson(response.data);
  }

  @override
  Future<SessionResponseModel> getSession(String token) async {
    final response = await _apiClient.get(
      '/api/mobile/client-auth/session',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return SessionResponseModel.fromJson(response.data);
  }

  @override
  Future<UpdateProfileResponseModel> updateProfile(String token, UpdateProfileRequestModel request) async {
    final response = await _apiClient.patch(
      '/api/mobile/client-auth/account',
      data: request.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return UpdateProfileResponseModel.fromJson(response.data);
  }

  @override
  Future<void> changePassword(String token, ChangePasswordRequestModel request) async {
    await _apiClient.post(
      '/api/mobile/client-auth/password/change',
      data: request.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  @override
  Future<RegisterResponseModel> requestEmailChange(String token, RequestEmailChangeRequestModel request) async {
    final response = await _apiClient.post(
      '/api/mobile/client-auth/email-change',
      data: request.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return RegisterResponseModel.fromJson(response.data);
  }

  @override
  Future<VerifyEmailChangeResponseModel> verifyEmailChange(String token, VerifyEmailChangeRequestModel request) async {
    final response = await _apiClient.post(
      '/api/mobile/client-auth/email-change/verify',
      data: request.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return VerifyEmailChangeResponseModel.fromJson(response.data);
  }

  @override
  Future<void> changePassword(String token, ChangePasswordRequestModel request) async {
    await _apiClient.post(
      '/api/mobile/client-auth/password/change',
      data: request.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}