/// The lawyer's own profile, as returned by `GET /lawyer/profile`.
///
/// The endpoint returns the raw `lawyers` row plus its specializations,
/// services, weekly availability and verification trail. Only the fields the
/// workspace actually shows are modelled; anything else stays on the server.
class LawyerProfile {
  final String id;
  final String professionalName;
  final String? professionalNameEn;
  final int experienceYears;
  final double consultationFee;
  final double? caseFeeMin;
  final double? caseFeeMax;
  final String currency;
  final String? location;
  final String? city;
  final String? bio;
  final List<String> languages;
  final double rating;
  final int reviewsCount;
  final int completedCasesCount;
  final bool acceptsOnline;
  final bool acceptsInperson;
  final String verificationStatus;
  final String profileStatus;
  final String? licenseNumber;
  final String? licenseAuthority;
  final String? barAssociation;
  final String? barNumber;
  final List<LawyerSpecialization> specializations;
  final List<LawyerService> services;
  final List<AvailabilitySlot> availability;
  final List<VerificationEvent> verification;

  LawyerProfile({
    required this.id,
    required this.professionalName,
    this.professionalNameEn,
    required this.experienceYears,
    required this.consultationFee,
    this.caseFeeMin,
    this.caseFeeMax,
    required this.currency,
    this.location,
    this.city,
    this.bio,
    this.languages = const [],
    required this.rating,
    required this.reviewsCount,
    required this.completedCasesCount,
    required this.acceptsOnline,
    required this.acceptsInperson,
    required this.verificationStatus,
    required this.profileStatus,
    this.licenseNumber,
    this.licenseAuthority,
    this.barAssociation,
    this.barNumber,
    this.specializations = const [],
    this.services = const [],
    this.availability = const [],
    this.verification = const [],
  });

  bool get isVerified => verificationStatus == 'verified';
  bool get isPublished => profileStatus == 'published';

  factory LawyerProfile.fromJson(Map<String, dynamic> json) => LawyerProfile(
        id: '${json['id']}',
        professionalName: json['professional_name'] ?? '',
        professionalNameEn: json['professional_name_en'],
        experienceYears: int.tryParse('${json['experience_years']}') ?? 0,
        consultationFee: double.tryParse('${json['consultation_fee']}') ?? 0,
        caseFeeMin: double.tryParse('${json['case_fee_min']}'),
        caseFeeMax: double.tryParse('${json['case_fee_max']}'),
        currency: json['currency'] ?? 'BHD',
        location: json['location'],
        city: json['city'],
        bio: json['bio'],
        // `languages` is stored as a JSON string in the column.
        languages: _stringList(json['languages']),
        rating: double.tryParse('${json['rating']}') ?? 0,
        reviewsCount: int.tryParse('${json['reviews_count']}') ?? 0,
        completedCasesCount: int.tryParse('${json['completed_cases_count']}') ?? 0,
        acceptsOnline: json['accepts_online'] == true || json['accepts_online'] == 1,
        acceptsInperson: json['accepts_inperson'] == true || json['accepts_inperson'] == 1,
        verificationStatus: json['verification_status'] ?? 'pending',
        profileStatus: json['profile_status'] ?? 'draft',
        licenseNumber: json['license_number'],
        licenseAuthority: json['license_authority'],
        barAssociation: json['bar_association'],
        barNumber: json['bar_number'],
        specializations: (json['specializations'] as List?)
                ?.map((e) => LawyerSpecialization.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        services: (json['services'] as List?)
                ?.map((e) => LawyerService.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        availability: (json['availability'] as List?)
                ?.map((e) => AvailabilitySlot.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        verification: (json['verification'] as List?)
                ?.map((e) => VerificationEvent.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  static List<String> _stringList(Object? raw) {
    if (raw is List) return raw.map((e) => e.toString()).toList();
    if (raw is String && raw.trim().isNotEmpty) {
      // The backend may hand back a JSON-encoded array.
      final inner = raw.replaceAll(RegExp(r'^\[|\]$'), '');
      return inner
          .split(',')
          .map((e) => e.replaceAll('"', '').trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }
}

class LawyerSpecialization {
  final String id;
  final String nameAr;
  final bool isPrimary;
  final int yearsExperience;

  LawyerSpecialization({
    required this.id,
    required this.nameAr,
    required this.isPrimary,
    required this.yearsExperience,
  });

  factory LawyerSpecialization.fromJson(Map<String, dynamic> json) => LawyerSpecialization(
        // `/lawyer/profile` returns the link row, where `id` is the join-table
        // id and `specialization_id` is the real specialization. Prefer the
        // latter so the value can be sent back to the sync endpoints; fall back
        // to `id` for directory payloads where the two coincide.
        id: '${json['specialization_id'] ?? json['id']}',
        nameAr: json['name_ar'] ?? '',
        isPrimary: json['is_primary'] == true || json['is_primary'] == 1,
        yearsExperience: int.tryParse('${json['years_experience']}') ?? 0,
      );
}

class LawyerService {
  final int id;
  final String nameAr;
  final String deliveryMode;
  final double fee;
  final int durationMinutes;

  LawyerService({
    required this.id,
    required this.nameAr,
    required this.deliveryMode,
    required this.fee,
    required this.durationMinutes,
  });

  factory LawyerService.fromJson(Map<String, dynamic> json) => LawyerService(
        id: int.parse(json['id'].toString()),
        nameAr: json['name_ar'] ?? '',
        deliveryMode: json['delivery_mode'] ?? 'any',
        fee: double.tryParse('${json['fee']}') ?? 0,
        durationMinutes: int.tryParse('${json['duration_minutes']}') ?? 30,
      );
}

class AvailabilitySlot {
  final int weekday; // 0 = Sunday .. 6 = Saturday
  final String startTime;
  final String endTime;
  final String? breakStart;
  final String? breakEnd;
  final int slotDurationMinutes;
  final String consultationType;

  AvailabilitySlot({
    required this.weekday,
    required this.startTime,
    required this.endTime,
    this.breakStart,
    this.breakEnd,
    required this.slotDurationMinutes,
    required this.consultationType,
  });

  static const weekdayNames = [
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  String get weekdayName => weekdayNames[weekday % 7];

  String get range => '$startTime – $endTime';

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) => AvailabilitySlot(
        weekday: int.tryParse('${json['weekday']}') ?? 0,
        startTime: '${json['start_time']}',
        endTime: '${json['end_time']}',
        breakStart: json['break_start'],
        breakEnd: json['break_end'],
        slotDurationMinutes: int.tryParse('${json['slot_duration_minutes']}') ?? 30,
        consultationType: json['consultation_type'] ?? 'any',
      );
}

class VerificationEvent {
  final String toStatus;
  final String? notes;
  final String createdAt;

  VerificationEvent({required this.toStatus, this.notes, required this.createdAt});

  factory VerificationEvent.fromJson(Map<String, dynamic> json) => VerificationEvent(
        toStatus: json['to_status'] ?? json['status'] ?? '',
        notes: json['notes'],
        createdAt: '${json['created_at']}',
      );
}

class BlockedDate {
  final String id;
  final String blockedDate;
  final bool allDay;
  final String? startTime;
  final String? endTime;
  final String reasonType;
  final String? reason;

  BlockedDate({
    required this.id,
    required this.blockedDate,
    required this.allDay,
    this.startTime,
    this.endTime,
    required this.reasonType,
    this.reason,
  });

  factory BlockedDate.fromJson(Map<String, dynamic> json) => BlockedDate(
        id: '${json['id']}',
        blockedDate: '${json['blocked_date']}',
        allDay: json['all_day'] == true || json['all_day'] == 1,
        startTime: json['start_time'],
        endTime: json['end_time'],
        reasonType: json['reason_type'] ?? 'other',
        reason: json['reason'],
      );
}
