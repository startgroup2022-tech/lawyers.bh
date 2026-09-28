class LegalCategory {
  final int id;
  final String nameAr;
  final String iconKey;

  LegalCategory({required this.id, required this.nameAr, required this.iconKey});

  factory LegalCategory.fromJson(Map<String, dynamic> json) => LegalCategory(
        id: int.parse(json['id'].toString()),
        nameAr: json['name_ar'],
        iconKey: json['icon_key'] ?? 'briefcase',
      );
}
