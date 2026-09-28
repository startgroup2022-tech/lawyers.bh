class Lawyer {
  final int id;
  final String name;
  final int categoryId;
  final String categoryName;
  final String location;
  final String? bio;
  final int experienceYears;
  final double consultationFee;
  final double rating;
  final int reviewsCount;
  final String? availabilityLabel;
  final List<String> tags;
  final bool isBookmarked;

  Lawyer({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.location,
    this.bio,
    required this.experienceYears,
    required this.consultationFee,
    required this.rating,
    required this.reviewsCount,
    this.availabilityLabel,
    this.tags = const [],
    this.isBookmarked = false,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    final letters = parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join();
    return letters;
  }

  factory Lawyer.fromJson(Map<String, dynamic> json) => Lawyer(
        id: int.parse(json['id'].toString()),
        name: json['name'] ?? '',
        // A lawyer may have no specialization yet, in which case the backend
        // sends null; treat that as "uncategorised" rather than crashing.
        categoryId: int.tryParse('${json['category_id']}') ?? 0,
        categoryName: json['category_name'] ?? '',
        location: json['location'] ?? '',
        bio: json['bio'],
        experienceYears: int.tryParse('${json['experience_years']}') ?? 0,
        consultationFee: double.tryParse('${json['consultation_fee']}') ?? 0,
        rating: double.tryParse('${json['rating']}') ?? 5.0,
        reviewsCount: int.tryParse('${json['reviews_count']}') ?? 0,
        availabilityLabel: json['availability_label'],
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        isBookmarked: json['is_bookmarked'] == true || json['is_bookmarked'] == 1,
      );
}
