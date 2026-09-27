import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lawyers_bh/domain/entities/user.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

@freezed
class LoginRequestModel with _$LoginRequestModel {
  const factory LoginRequestModel({
    required String phone,
    required String password,
    bool? rememberMe,
  }) = _LoginRequestModel;

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) => _$LoginRequestModelFromJson(json);
}

@freezed
class RegisterRequestModel with _$RegisterRequestModel {
  const factory RegisterRequestModel({
    required String phone,
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) = _RegisterRequestModel;

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) => _$RegisterRequestModelFromJson(json);
}

@freezed
class VerifyOtpRequestModel with _$VerifyOtpRequestModel {
  const factory VerifyOtpRequestModel({
    required String phone,
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
    required UserModel user,
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required String tokenType,
  }) = _AuthResponseModel;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => _$AuthResponseModelFromJson(json);
}

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String phone,
    required String fullName,
    String? avatarUrl,
    required String role,
    required String status,
    required String verificationStatus,
    String? idCardUrl,
    String? licenseUrl,
    required String createdAt,
    String? lastLoginAt,
    required bool notificationsEnabled,
    required bool darkMode,
    required String preferredLanguage,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  User toEntity() {
    return User(
      id: id,
      email: email,
      phone: phone,
      fullName: fullName,
      avatarUrl: avatarUrl,
      role: UserRole.values.byName(role),
      status: UserStatus.values.byName(status),
      verificationStatus: VerificationStatus.values.byName(verificationStatus),
      idCardUrl: idCardUrl,
      licenseUrl: licenseUrl,
      createdAt: DateTime.parse(createdAt),
      lastLoginAt: lastLoginAt != null ? DateTime.parse(lastLoginAt!) : null,
      notificationsEnabled: notificationsEnabled,
      darkMode: darkMode,
      preferredLanguage: preferredLanguage,
    );
  }
}