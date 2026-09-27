import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lawyers_bh/domain/entities/lawyer.dart';

part 'lawyer_models.freezed.dart';
part 'lawyer_models.g.dart';

@freezed
class LawyerModel with _$LawyerModel {
  const factory LawyerModel({
    required String id,
    required String countryCode,
    required String fullNameAr,
    required String fullNameEn,
    String? phone,
    String? email,
    required String status,
    String? subscriptionType,
    String? fullName,
    String? specialty,
    String? location,
    double? rating,
    int? reviewsCount,
    int? experienceYears,
    double? consultationFee,
    String? badgeText,
    String? badgeType,
    List<String>? tags,
    String? bio,
    String? avatarUrl,
    bool? isAvailable,
    List<String>? availableConsultationTypes,
    List<String>? languages,
    String? createdAt,
    String? lastActiveAt,
    // Public lawyer fields
    String? slug,
    String? subscriptionTypeDisplay,
    List<String>? subscriptionTypes,
    String? nameAr,
    String? nameEn,
    String? subtitleAr,
    String? subtitleEn,
    String? registrationNo,
    String? membershipNo,
    String? registrationLevel,
    int? experienceYearsInt,
    String? language,
    String? workingHours,
    String? specialtyMain,
    List<String>? specialtySubs,
    List<String>? specialties,
    String? image,
    String? badgeTypeDisplay,
    double? ratingDouble,
    int? reviewCountInt,
    List<ReviewCommentModel>? reviewComments,
    String? licenseExpiryDate,
    String? registrationNoDisplay,
    String? membershipNoDisplay,
    String? registrationLevelDisplay,
    int? experienceYearsDisplay,
    String? languageDisplay,
    String? workingHoursDisplay,
    String? specialtyMainDisplay,
    List<String>? specialtySubsDisplay,
    List<String>? specialtiesDisplay,
    String? imageDisplay,
    String? badgeTypeDisplayValue,
    double? ratingDisplay,
    int? reviewCountDisplay,
    List<ReviewCommentModel>? reviewCommentsDisplay,
    String? licenseExpiryDateDisplay,
  }) = _LawyerModel;

  factory LawyerModel.fromJson(Map<String, dynamic> json) => _$LawyerModelFromJson(json);

  Lawyer toEntity() {
    return Lawyer(
      id: id,
      fullName: fullNameAr ?? fullNameEn ?? fullName ?? nameAr ?? nameEn ?? '',
      specialty: specialtyMain ?? specialtyMainDisplay ?? specialty ?? '',
      location: location ?? '',
      rating: (ratingDouble ?? rating ?? 0.0),
      reviewsCount: reviewsCountInt ?? reviewCountInt ?? reviewCountDisplay ?? 0,
      experienceYears: experienceYearsInt ?? experienceYearsDisplay ?? experienceYears ?? 0,
      consultationFee: consultationFee ?? 0.0,
      badgeText: badgeText ?? badgeTypeDisplay ?? badgeTypeDisplayValue ?? '',
      badgeType: LawyerBadgeType.values.byName(badgeType ?? badgeTypeDisplay ?? badgeTypeDisplayValue ?? 'verified'),
      tags: tags ?? specialties ?? specialtiesDisplay ?? [],
      bio: bio ?? '',
      avatarUrl: avatarUrl ?? image ?? imageDisplay,
      isAvailable: isAvailable ?? true,
      availableConsultationTypes: availableConsultationTypes?.map((e) => ConsultationType.values.byName(e)).toList() ?? [],
      languages: languages ?? [],
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : DateTime.now(),
      lastActiveAt: lastActiveAt != null ? DateTime.parse(lastActiveAt!) : null,
    );
  }

  // Factory for mobile lawyers list API
  factory LawyerModel.fromMobileListJson(Map<String, dynamic> json) {
    return LawyerModel(
      id: json['id'] as String,
      countryCode: json['countryCode'] as String,
      fullNameAr: json['fullNameAr'] as String?,
      fullNameEn: json['fullNameEn'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      status: json['status'] as String?,
      subscriptionType: json['subscriptionType'] as String?,
      status: json['status'] as String?,
    );
  }

  // Factory for public lawyer list API
  factory LawyerModel.fromPublicListJson(Map<String, dynamic> json) {
    return LawyerModel(
      id: json['id'] as String,
      countryCode: json['countryCode'] as String,
      slug: json['slug'] as String?,
      subscriptionType: json['subscriptionType'] as String?,
      subscriptionTypes: (json['subscriptionTypes'] as List<dynamic>?)?.cast<String>(),
      nameAr: json['nameAr'] as String?,
      nameEn: json['nameEn'] as String?,
      subtitleAr: json['subtitleAr'] as String?,
      subtitleEn: json['subtitleEn'] as String?,
      registrationNo: json['registrationNo'] as String?,
      membershipNo: json['membershipNo'] as String?,
      registrationLevel: json['registrationLevel'] as String?,
      experienceYears: (json['experienceYears'] as num?)?.toInt(),
      language: json['language'] as String?,
      workingHours: json['workingHours'] as String?,
      specialtyMain: json['specialtyMain'] as String?,
      specialtySubs: (json['specialtySubs'] as List<dynamic>?)?.cast<String>(),
      specialties: (json['specialties'] as List<dynamic>?)?.cast<String>(),
      image: json['image'] as String?,
      badgeType: json['badgeType'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewsCount: (json['reviewCount'] as num?)?.toInt(),
      reviewComments: (json['reviewComments'] as List<dynamic>?)?.map((e) => ReviewCommentModel.fromJson(e as Map<String, dynamic>)).toList(),
      licenseExpiryDate: json['licenseExpiryDate'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  // Factory for lawyer detail API
  factory LawyerModel.fromDetailJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return LawyerModel(
      id: data['id'] as String,
      countryCode: data['countryCode'] as String,
      fullNameAr: data['fullNameAr'] as String?,
      fullNameEn: data['fullNameEn'] as String?,
      phone: data['phone'] as String?,
      email: data['email'] as String?,
      licenseNumber: data['licenseNumber'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
      status: data['status'] as String?,
      isActive: data['isActive'] as bool?,
      isEmergencyReady: data['isEmergencyReady'] as bool?,
      rating: (data['rating'] as num?)?.toDouble(),
      totalRequests: (data['totalRequests'] as num?)?.toInt(),
      completedRequests: (data['completedRequests'] as num?)?.toInt(),
      status: data['status'] as String?,
      isAvailable: data['isAvailable'] as bool?,
      stats: data['stats'] as Map<String, dynamic>?,
    );
  }
}

@freezed
class ReviewCommentModel with _$ReviewCommentModel {
  const factory ReviewCommentModel({
    required int stars,
    required String comment,
    String? createdAt,
    required String customerName,
  }) = _ReviewCommentModel;

  factory ReviewCommentModel.fromJson(Map<String, dynamic> json) => _$ReviewCommentModelFromJson(json);
}

@freezed
class LawyersListResponseModel with _$LawyersListResponseModel {
  const factory LawyersListResponseModel({
    required List<LawyerModel> data,
    required int total,
    required int page,
    required int limit,
    required int totalPages,
    bool? ok,
    String? countryCode,
  }) = _LawyersListResponseModel;

  factory LawyersListResponseModel.fromJson(Map<String, dynamic> json) => _$LawyersListResponseModelFromJson(json);
}

@freezed
class LawyerDetailResponseModel with _$LawyerDetailResponseModel {
  const factory LawyerDetailResponseModel({
    required bool success,
    required LawyerModel data,
    String? message,
  }) = _LawyerDetailResponseModel;

  factory LawyerDetailResponseModel.fromJson(Map<String, dynamic> json) => _$LawyerDetailResponseModelFromJson(json);
}

@freezed
class LawyersListMobileResponseModel with _$LawyersListMobileResponseModel {
  const factory LawyersListMobileResponseModel({
    required bool ok,
    required String countryCode,
    required List<LawyerModel> data,
  }) = _LawyersListMobileResponseModel;

  factory LawyersListMobileResponseModel.fromJson(Map<String, dynamic> json) => _$LawyersListMobileResponseModelFromJson(json);
}