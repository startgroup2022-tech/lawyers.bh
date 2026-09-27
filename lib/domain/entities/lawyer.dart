import 'package:equatable/equatable.dart';

enum ConsultationType { video, voice, inPerson }

enum LawyerBadgeType { freeConsultation, acceptedAtCassation, availableToday, verified }

class Lawyer extends Equatable {
  final String id;
  final String fullName;
  final String specialty;
  final String location;
  final double rating;
  final int reviewsCount;
  final int experienceYears;
  final double consultationFee;
  final String badgeText;
  final LawyerBadgeType badgeType;
  final List<String> tags;
  final String bio;
  final String? avatarUrl;
  final bool isAvailable;
  final List<ConsultationType> availableConsultationTypes;
  final List<String> languages;
  final DateTime createdAt;
  final DateTime? lastActiveAt;

  const Lawyer({
    required this.id,
    required this.fullName,
    required this.specialty,
    required this.location,
    required this.rating,
    required this.reviewsCount,
    required this.experienceYears,
    required this.consultationFee,
    required this.badgeText,
    required this.badgeType,
    required this.tags,
    required this.bio,
    this.avatarUrl,
    required this.isAvailable,
    required this.availableConsultationTypes,
    required this.languages,
    required this.createdAt,
    this.lastActiveAt,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  String get formattedFee => '${consultationFee.toStringAsFixed(0)} د.ب';

  String get formattedExperience => '$experienceYears سنة خبرة';

  String get formattedRating => '★ $rating';

  String get formattedReviews => '$reviewsCount ${reviewsCount == 1 ? 'تقييم' : 'تقييمات'}';

  @override
  List<Object?> get props => [
    id, fullName, specialty, location, rating, reviewsCount, experienceYears,
    consultationFee, badgeText, badgeType, tags, bio, avatarUrl, isAvailable,
    availableConsultationTypes, languages, createdAt, lastActiveAt,
  ];

  Lawyer copyWith({
    String? id,
    String? fullName,
    String? specialty,
    String? location,
    double? rating,
    int? reviewsCount,
    int? experienceYears,
    double? consultationFee,
    String? badgeText,
    LawyerBadgeType? badgeType,
    List<String>? tags,
    String? bio,
    String? avatarUrl,
    bool? isAvailable,
    List<ConsultationType>? availableConsultationTypes,
    List<String>? languages,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return Lawyer(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      specialty: specialty ?? this.specialty,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      experienceYears: experienceYears ?? this.experienceYears,
      consultationFee: consultationFee ?? this.consultationFee,
      badgeText: badgeText ?? this.badgeText,
      badgeType: badgeType ?? this.badgeType,
      tags: tags ?? this.tags,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      availableConsultationTypes: availableConsultationTypes ?? this.availableConsultationTypes,
      languages: languages ?? this.languages,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}

class LawyerFilter extends Equatable {
  final String? specialty;
  final String? location;
  final double? minRating;
  final double? maxFee;
  final int? minExperience;
  final List<ConsultationType>? consultationTypes;
  final List<LawyerBadgeType>? badges;
  final String? searchQuery;
  final int page;
  final int limit;

  const LawyerFilter({
    this.specialty,
    this.location,
    this.minRating,
    this.maxFee,
    this.minExperience,
    this.consultationTypes,
    this.badges,
    this.searchQuery,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [
    specialty, location, minRating, maxFee, minExperience,
    consultationTypes, badges, searchQuery, page, limit,
  ];

  LawyerFilter copyWith({
    String? specialty,
    String? location,
    double? minRating,
    double? maxFee,
    int? minExperience,
    List<ConsultationType>? consultationTypes,
    List<LawyerBadgeType>? badges,
    String? searchQuery,
    int? page,
    int? limit,
  }) {
    return LawyerFilter(
      specialty: specialty ?? this.specialty,
      location: location ?? this.location,
      minRating: minRating ?? this.minRating,
      maxFee: maxFee ?? this.maxFee,
      minExperience: minExperience ?? this.minExperience,
      consultationTypes: consultationTypes ?? this.consultationTypes,
      badges: badges ?? this.badges,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}