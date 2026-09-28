/// A lawyer as returned by `GET /api/mobile/lawyers`.
///
/// The directory exposes the public identity fields only: name, phone, email,
/// status and subscription type. Rating, fee, bio and location are not part of
/// this endpoint, so they are absent here rather than invented.
class Lawyer {
  final String id;
  final String name;
  final String? nameEn;
  final String? phone;
  final String? email;
  final String status;
  final String? subscriptionType;
  final String countryCode;

  Lawyer({
    required this.id,
    required this.name,
    this.nameEn,
    this.phone,
    this.email,
    this.status = 'approved',
    this.subscriptionType,
    this.countryCode = 'BH',
  });

  String get initials {
    final source = name.trim().isNotEmpty ? name.trim() : (nameEn ?? '');
    final parts = source.split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join();
  }

  /// Whether the lawyer's subscription covers emergency (SOS) work.
  bool get isEmergencyReady =>
      subscriptionType == 'emergency' || subscriptionType == 'sos';

  factory Lawyer.fromJson(Map<String, dynamic> json) => Lawyer(
        id: json['id']?.toString() ?? '',
        name: (json['fullNameAr'] ?? json['name'] ?? json['fullNameEn'] ?? '').toString(),
        nameEn: (json['fullNameEn'] ?? json['name_en'])?.toString(),
        phone: json['phone']?.toString(),
        email: json['email']?.toString(),
        status: json['status']?.toString() ?? 'approved',
        subscriptionType: json['subscriptionType']?.toString(),
        countryCode: json['countryCode']?.toString() ?? 'BH',
      );
}
