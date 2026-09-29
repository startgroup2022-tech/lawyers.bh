/// A lawyer as returned by `GET /api/mobile/lawyers`.
///
/// The directory publishes the real published profile: identity and contact
/// fields plus the professional detail the platform already computes for the
/// website (photo, title, experience, specialties, languages, working hours and
/// rating). Anything a lawyer has not filled in arrives empty and is rendered as
/// an explicit gap, never invented.
class Lawyer {
  final String id;
  final String name;
  final String? nameEn;
  final String? phone;
  final String? email;
  final String status;
  final String? subscriptionType;
  final List<String> subscriptionTypes;
  final String countryCode;

  final String? photoUrl;
  final String? professionalTitle;
  final String? professionalTitleEn;
  final int experienceYears;
  final String specialtyMain;
  final List<String> specialties;
  final List<String> languages;
  final String workingHours;
  final String? registrationNo;
  final String? registrationLevel;
  final double rating;
  final int reviewCount;

  Lawyer({
    required this.id,
    required this.name,
    this.nameEn,
    this.phone,
    this.email,
    this.status = 'approved',
    this.subscriptionType,
    this.subscriptionTypes = const [],
    this.countryCode = 'BH',
    this.photoUrl,
    this.professionalTitle,
    this.professionalTitleEn,
    this.experienceYears = 0,
    this.specialtyMain = '',
    this.specialties = const [],
    this.languages = const [],
    this.workingHours = '',
    this.registrationNo,
    this.registrationLevel,
    this.rating = 0,
    this.reviewCount = 0,
  });

  String get initials {
    final source = name.trim().isNotEmpty ? name.trim() : (nameEn ?? '');
    final parts = source.split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join();
  }

  /// Whether the lawyer's subscription covers emergency (SOS) work.
  bool get isEmergencyReady =>
      subscriptionType == 'emergency' ||
      subscriptionType == 'sos' ||
      subscriptionTypes.any((t) => t == 'emergency' || t == 'sos');

  bool get hasPhoto => (photoUrl ?? '').trim().isNotEmpty;

  bool get hasRating => reviewCount > 0 && rating > 0;

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e?.toString() ?? '')
          .where((e) => e.trim().isNotEmpty)
          .toList(growable: false);
    }
    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(RegExp(r'[,\u060C]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  factory Lawyer.fromJson(Map<String, dynamic> json) => Lawyer(
        id: json['id']?.toString() ?? '',
        name: (json['fullNameAr'] ?? json['name'] ?? json['fullNameEn'] ?? '').toString(),
        nameEn: (json['fullNameEn'] ?? json['name_en'])?.toString(),
        phone: json['phone']?.toString(),
        email: json['email']?.toString(),
        status: json['status']?.toString() ?? 'approved',
        subscriptionType: json['subscriptionType']?.toString(),
        subscriptionTypes: _stringList(json['subscriptionTypes']),
        countryCode: json['countryCode']?.toString() ?? 'BH',
        photoUrl: json['profileImageUrl']?.toString(),
        professionalTitle: json['professionalTitleAr']?.toString(),
        professionalTitleEn: json['professionalTitleEn']?.toString(),
        experienceYears: int.tryParse('${json['experienceYears']}') ?? 0,
        specialtyMain: json['specialtyMain']?.toString() ?? '',
        specialties: _stringList(json['specialties']),
        languages: _stringList(json['languages']),
        workingHours: json['workingHours']?.toString() ?? '',
        registrationNo: json['registrationNo']?.toString(),
        registrationLevel: json['registrationLevel']?.toString(),
        rating: double.tryParse('${json['rating']}') ?? 0,
        reviewCount: int.tryParse('${json['reviewCount']}') ?? 0,
      );
}
