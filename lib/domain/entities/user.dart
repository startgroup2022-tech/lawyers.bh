import 'package:equatable/equatable.dart';

enum UserRole { client, lawyer, admin }

enum UserStatus { active, inactive, pending, suspended }

enum VerificationStatus { unverified, pending, verified, rejected }

class User extends Equatable {
  final String id;
  final String email;
  final String phone;
  final String fullName;
  final String? avatarUrl;
  final UserRole role;
  final UserStatus status;
  final VerificationStatus verificationStatus;
  final String? idCardUrl;
  final String? licenseUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool notificationsEnabled;
  final bool darkMode;
  final String preferredLanguage;

  const User({
    required this.id,
    required this.email,
    required this.phone,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    required this.status,
    required this.verificationStatus,
    this.idCardUrl,
    this.licenseUrl,
    required this.createdAt,
    this.lastLoginAt,
    required this.notificationsEnabled,
    required this.darkMode,
    required this.preferredLanguage,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  List<Object?> get props => [
    id, email, phone, fullName, avatarUrl, role, status, verificationStatus,
    idCardUrl, licenseUrl, createdAt, lastLoginAt, notificationsEnabled,
    darkMode, preferredLanguage,
  ];

  User copyWith({
    String? id,
    String? email,
    String? phone,
    String? fullName,
    String? avatarUrl,
    UserRole? role,
    UserStatus? status,
    VerificationStatus? verificationStatus,
    String? idCardUrl,
    String? licenseUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? notificationsEnabled,
    bool? darkMode,
    String? preferredLanguage,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      idCardUrl: idCardUrl ?? this.idCardUrl,
      licenseUrl: licenseUrl ?? this.licenseUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkMode: darkMode ?? this.darkMode,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }
}

class AuthTokens extends Equatable {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresIn, tokenType];
}