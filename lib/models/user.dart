/// The signed-in account, whichever door it came through.
///
/// The mobile client identity is its own record (`mobile_client_accounts`),
/// addressed by a UUID and identified by email + phone. A lawyer is a separate
/// record (`bahrain_lawyers`) that signs in with a licence number + password.
/// The two are disjoint — the same email can be both — and neither session
/// carries a `role` field, so the account kind comes from the sign-in door,
/// never from a role claim in the payload.
enum AccountKind {
  /// Signed in through `/api/mobile/client-auth/*` (email + password).
  client,

  /// Signed in through `/api/lawyers/login` (licence number + password).
  lawyer,
}

class AppRoles {
  static const client = 'client';
  static const lawyer = 'lawyer';
  static const lawFirmOwner = 'law_firm_owner';
  static const lawFirmManager = 'law_firm_manager';
  static const lawyerStaff = 'lawyer_staff';
  static const admin = 'admin';

  /// Roles that open the professional (lawyer) workspace rather than the
  /// client one. Used only when a backend actually returns roles — the mobile
  /// sessions do not.
  static const professional = {lawyer, lawFirmOwner, lawFirmManager, lawyerStaff};
}

class AppUser {
  final String id;
  final String phone;
  final String? name;
  final String role;

  /// Which sign-in door this session came through. The authoritative signal for
  /// [isProfessional] on mobile, because the mobile sessions carry no role.
  final AccountKind kind;

  /// Every role the account holds. Populated only by backends that expose
  /// roles/permissions (the professional portals); empty for mobile sessions.
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
    this.kind = AccountKind.client,
    this.roles = const [],
    this.permissions = const [],
    this.email,
    this.avatarPath,
    this.preferredLanguage,
    this.isVerified = false,
  });

  /// True when this is a lawyer session.
  ///
  /// The account [kind] decides it: a session opened through the lawyer door is
  /// a lawyer, a session opened through the client door is a client. The role
  /// lists are still honoured for any future backend that returns them, but they
  /// are never required — the mobile sessions send none.
  bool get isProfessional {
    if (kind == AccountKind.lawyer) return true;
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
  ///
  /// [kind] is the sign-in door, not a claim from the payload.
  factory AppUser.fromJson(Map<String, dynamic> json, {AccountKind kind = AccountKind.client}) =>
      AppUser(
        id: json['id']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        name: (json['fullName'] ?? json['name'])?.toString(),
        role: json['role']?.toString() ??
            (kind == AccountKind.lawyer ? AppRoles.lawyer : AppRoles.client),
        kind: kind,
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
