import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lawyers_bh/domain/entities/lawyer.dart';

part 'lawyer_models.freezed.dart';
part 'lawyer_models.g.dart';

@freezed
class LawyerModel with _$LawyerModel {
  const factory LawyerModel({
    required String id,
    required String fullName,
    required String specialty,
    required String location,
    required double rating,
    required int reviewsCount,
    required int experienceYears,
    required double consultationFee,
    required String badgeText,
    required String badgeType,
    required List<String> tags,
    required String bio,
    String? avatarUrl,
    required bool isAvailable,
    required List<String> availableConsultationTypes,
    required List<String> languages,
    required String createdAt,
    String? lastActiveAt,
  }) = _LawyerModel;

  factory LawyerModel.fromJson(Map<String, dynamic> json) => _$LawyerModelFromJson(json);

  Lawyer toEntity() {
    return Lawyer(
      id: id,
      fullName: fullName,
      specialty: specialty,
      location: location,
      rating: rating,
      reviewsCount: reviewsCount,
      experienceYears: experienceYears,
      consultationFee: consultationFee,
      badgeText: badgeText,
      badgeType: LawyerBadgeType.values.byName(badgeType),
      tags: tags,
      bio: bio,
      avatarUrl: avatarUrl,
      isAvailable: isAvailable,
      availableConsultationTypes: availableConsultationTypes
          .map((e) => ConsultationType.values.byName(e))
          .toList(),
      languages: languages,
      createdAt: DateTime.parse(createdAt),
      lastActiveAt: lastActiveAt != null ? DateTime.parse(lastActiveAt!) : null,
    );
  }
}

@freezed
class LawyersListResponseModel with _$LawyersListResponseModel {
  const factory LawyersListResponseModel({
    required List<LawyerModel> data,
    required int total,
    required int page,
    required int limit,
    required int totalPages,
  }) = _LawyersListResponseModel;

  factory LawyersListResponseModel.fromJson(Map<String, dynamic> json) => _$LawyersListResponseModelFromJson(json);
}