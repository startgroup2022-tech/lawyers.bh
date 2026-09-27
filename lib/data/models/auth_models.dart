import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lawyers_bh/domain/entities/user.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

@freezed
class LoginRequestModel with _$LoginRequestModel {
  const factory LoginRequestModel({
    required String email,
    required String password,
  }) = _LoginRequestModel;

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) => _$LoginRequestModelFromJson(json);
}

@freezed
class RegisterRequestModel with _$RegisterRequestModel {
  const factory RegisterRequestModel({
    required String email,
    required String fullName,
    required String phone,
    required String password,
    required String locale,
  }) = _RegisterRequestModel;

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) => _$RegisterRequestModelFromJson(json);
}

@freezed
class VerifyOtpRequestModel with _$VerifyOtpRequestModel {
  const factory VerifyOtpRequestModel({
    required String id,
    required String code,
  }) = _VerifyOtpRequestModel;

  factory VerifyOtpRequestModel.fromJson(Map<String, dynamic> json) => _$VerifyOtpRequestModelFromJson(json);
}

@freezed
class ChangePasswordRequestModel with _$ChangePasswordRequestModel {
  const factory ChangePasswordRequestModel({
    required String currentPassword,
    required String newPassword,
  }) = _ChangePasswordRequestModel;

  factory ChangePasswordRequestModel.fromJson(Map<String, dynamic> json) => _$ChangePasswordRequestModelFromJson(json);
}

@freezed
class AuthResponseModel with _$AuthResponseModel {
  const factory AuthResponseModel({
    required String token,
    required ClientModel client,
    required String expiresAt,
  }) = _AuthResponseModel;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => _$AuthResponseModelFromJson(json);
}

@freezed
class ClientModel with _$ClientModel {
  const factory ClientModel({
    required String id,
    required String email,
    required String fullName,
    required String phone,
  }) = _ClientModel;

  factory ClientModel.fromJson(Map<String, dynamic> json) => _$ClientModelFromJson(json);

  User toEntity() {
    return User(
      id: id,
      email: email,
      phone: phone,
      fullName: fullName,
      avatarUrl: null,
      role: UserRole.client,
      status: UserStatus.active,
      verificationStatus: VerificationStatus.verified,
      idCardUrl: null,
      licenseUrl: null,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      notificationsEnabled: true,
      darkMode: false,
      preferredLanguage: 'ar',
    );
  }
}

@freezed
class AuthResponseModel with _$AuthResponseModel {
  const factory AuthResponseModel({
    required String token,
    required ClientModel client,
    required String expiresAt,
  }) = _AuthResponseModel;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => _$AuthResponseModelFromJson(json);
}

@freezed
class VerifyOtpResponseModel with _$VerifyOtpResponseModel {
  const factory VerifyOtpResponseModel({
    required String token,
    required ClientModel client,
    required String expiresAt,
  }) = _VerifyOtpResponseModel;

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) => _$VerifyOtpResponseModelFromJson(json);
}

@freezed
class RegisterResponseModel with _$RegisterResponseModel {
  const factory RegisterResponseModel({
    required String challengeId,
    required int retryAfterSeconds,
    required int expiresInSeconds,
  }) = _RegisterResponseModel;

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) => _$RegisterResponseModelFromJson(json);
}

@freezed
class VerifyOtpResponseModel with _$VerifyOtpResponseModel {
  const factory VerifyOtpResponseModel({
    required String token,
    required ClientModel client,
    required String expiresAt,
  }) = _VerifyOtpResponseModel;

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) => _$VerifyOtpResponseModelFromJson(json);
}

@freezed
class ForgotPasswordRequestModel with _$ForgotPasswordRequestModel {
  const factory ForgotPasswordRequestModel({
    required String email,
    required String locale,
  }) = _ForgotPasswordRequestModel;

  factory ForgotPasswordRequestModel.fromJson(Map<String, dynamic> json) => _$ForgotPasswordRequestModelFromJson(json);
}

@freezed
class ForgotPasswordResponseModel with _$ForgotPasswordResponseModel {
  const factory ForgotPasswordResponseModel({
    required String challengeId,
    required int retryAfterSeconds,
    required int expiresInSeconds,
  }) = _ForgotPasswordResponseModel;

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) => _$ForgotPasswordResponseModelFromJson(json);
}

@freezed
class VerifyOtpRequestModel with _$VerifyOtpRequestModel {
  const factory VerifyOtpRequestModel({
    required String id,
    required String code,
  }) = _VerifyOtpRequestModel;

  factory VerifyOtpRequestModel.fromJson(Map<String, dynamic> json) => _$VerifyOtpRequestModelFromJson(json);
}

@freezed
class VerifyOtpResponseModel with _$VerifyOtpResponseModel {
  const factory VerifyOtpResponseModel({
    required String token,
    required ClientModel client,
    required String expiresAt,
  }) = _VerifyOtpResponseModel;

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) => _$VerifyOtpResponseModelFromJson(json);
}

@freezed
class ChangePasswordRequestModel with _$ChangePasswordRequestModel {
  const factory ChangePasswordRequestModel({
    required String currentPassword,
    required String newPassword,
  }) = _ChangePasswordRequestModel;

  factory ChangePasswordRequestModel.fromJson(Map<String, dynamic> json) => _$ChangePasswordRequestModelFromJson(json);
}

@freezed
class UpdateProfileRequestModel with _$UpdateProfileRequestModel {
  const factory UpdateProfileRequestModel({
    required String fullName,
    required String phone,
  }) = _UpdateProfileRequestModel;

  factory UpdateProfileRequestModel.fromJson(Map<String, dynamic> json) => _$UpdateProfileRequestModelFromJson(json);
}

@freezed
class UpdateProfileResponseModel with _$UpdateProfileResponseModel {
  const factory UpdateProfileResponseModel({
    required ClientModel client,
  }) = _UpdateProfileResponseModel;

  factory UpdateProfileResponseModel.fromJson(Map<String, dynamic> json) => _$UpdateProfileResponseModelFromJson(json);
}

@freezed
class RequestEmailChangeRequestModel with _$RequestEmailChangeRequestModel {
  const factory RequestEmailChangeRequestModel({
    required String email,
    required String currentPassword,
    required String locale,
  }) = _RequestEmailChangeRequestModel;

  factory RequestEmailChangeRequestModel.fromJson(Map<String, dynamic> json) => _$RequestEmailChangeRequestModelFromJson(json);
}

@freezed
class RequestEmailChangeResponseModel with _$RequestEmailChangeResponseModel {
  const factory RequestEmailChangeResponseModel({
    required String challengeId,
    required int retryAfterSeconds,
    required int expiresInSeconds,
  }) = _RequestEmailChangeResponseModel;

  factory RequestEmailChangeResponseModel.fromJson(Map<String, dynamic> json) => _$RequestEmailChangeResponseModelFromJson(json);
}

@freezed
class VerifyEmailChangeRequestModel with _$VerifyEmailChangeRequestModel {
  const factory VerifyEmailChangeRequestModel({
    required String id,
    required String code,
  }) = _VerifyEmailChangeRequestModel;

  factory VerifyEmailChangeRequestModel.fromJson(Map<String, dynamic> json) => _$VerifyEmailChangeRequestModelFromJson(json);
}

@freezed
class VerifyEmailChangeResponseModel with _$VerifyEmailChangeResponseModel {
  const factory VerifyEmailChangeResponseModel({
    required ClientModel client,
  }) = _VerifyEmailChangeResponseModel;

  factory VerifyEmailChangeResponseModel.fromJson(Map<String, dynamic> json) => _$VerifyEmailChangeResponseModelFromJson(json);
}

@freezed
class ChangePasswordRequestModel with _$ChangePasswordRequestModel {
  const factory ChangePasswordRequestModel({
    required String currentPassword,
    required String newPassword,
  }) = _ChangePasswordRequestModel;

  factory ChangePasswordRequestModel.fromJson(Map<String, dynamic> json) => _$ChangePasswordRequestModelFromJson(json);
}

@freezed
class SessionResponseModel with _$SessionResponseModel {
  const factory SessionResponseModel({
    required ClientModel? client,
  }) = _SessionResponseModel;

  factory SessionResponseModel.fromJson(Map<String, dynamic> json) => _$SessionResponseModelFromJson(json);
}