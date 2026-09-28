/// The signed-in client, as returned by `/api/mobile/client-auth/*`.
///
/// The mobile client identity is its own record (`mobile_client_accounts`),
/// addressed by a UUID and identified by email + phone. It is deliberately not
/// the lawyer identity used by the professional portal: a lawyer signs in to
/// the lawyer app with their own credentials, and the same email can exist as
/// both a client and a lawyer without the two being the same account.
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
  final String id;
  final String phone;
  final String? name;
  final String role;

  /// Every role the account holds. Populated only by backends that expose
  /// roles/permissions (the professional portals); empty for mobile clients.
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
    this.role = AppRoles.client,
    this.roles = const [],
    this.permissions = const [],
    this.email,
    this.avatarPath,
    this.preferredLanguage,
    this.isVerified = false,
  });

  /// True when the account has any professional role. The primary `role` is
  /// checked too because a verify response may carry that field alone.
  bool get isProfessional {
    if (AppRoles.professional.contains(role)) return true;
    return roles.any(AppRoles.professional.contains);
  }

  bool hasRole(String slug) => role == slug || roles.contains(slug);

  bool can(String permission) => permissions.contains(permission);

  String get displayName {
    final n = name;
    if (n != null && n.trim().isNotEmpty) return n;
    return phone.isNotEmpty ? phone : (email ?? '');
  }

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join();
  }

  /// Parses the mobile client shape (`{id, email, fullName, phone}`) and
  /// tolerates the richer professional shape (`{id, name, role, roles, ...}`).
  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        name: (json['fullName'] ?? json['name'])?.toString(),
        role: json['role']?.toString() ?? AppRoles.client,
        roles: (json['roles'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        permissions:
            (json['permissions'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        email: json['email']?.toString(),
        avatarPath: json['avatar_path']?.toString(),
        preferredLanguage: json['preferred_language']?.toString(),
        isVerified: json['is_verified'] == true ||
            json['is_verified'] == 1 ||
            json['emailVerifiedAt'] != null,
      );
}
