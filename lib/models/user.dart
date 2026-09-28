/// Roles the backend can grant. `users.role` is the primary one; a user may
/// also hold extra roles through `user_roles`.
class AppRoles {
  static const client = 'client';
  static const lawyer = 'lawyer';
  static const lawFirmOwner = 'law_firm_owner';
  static const lawFirmManager = 'law_firm_manager';
  static const lawyerStaff = 'lawyer_staff';
  static const admin = 'admin';

  /// Roles that open the professional (lawyer) workspace rather than the
  /// client one.
  static const professional = {lawyer, lawFirmOwner, lawFirmManager, lawyerStaff};
}

class AppUser {
  final int id;
  final String phone;
  final String? name;
  final String role;

  /// Every role the account holds, as returned by `GET /auth/me`.
  final List<String> roles;

  /// Granted permission slugs, e.g. `leads.view`.
  final List<String> permissions;

  final String? email;
  final String? avatarPath;
  final String? preferredLanguage;
  final bool isVerified;

  AppUser({
    required this.id,
    required this.phone,
    this.name,
    required this.role,
    this.roles = const [],
    this.permissions = const [],
    this.email,
    this.avatarPath,
    this.preferredLanguage,
    this.isVerified = false,
  });

  /// True when the account has any professional role. The primary `role` is
  /// checked too because the OTP verify response carries that field alone.
  bool get isProfessional {
    if (AppRoles.professional.contains(role)) return true;
    return roles.any(AppRoles.professional.contains);
  }

  bool hasRole(String slug) => role == slug || roles.contains(slug);

  bool can(String permission) => permissions.contains(permission);

  String get displayName => (name == null || name!.trim().isEmpty) ? phone : name!;

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join();
  }

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: int.parse(json['id'].toString()),
        phone: json['phone'],
        name: json['name'],
        role: json['role'] ?? 'client',
        roles: (json['roles'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        permissions:
            (json['permissions'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        email: json['email'],
        avatarPath: json['avatar_path'],
        preferredLanguage: json['preferred_language'],
        isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      );
}
