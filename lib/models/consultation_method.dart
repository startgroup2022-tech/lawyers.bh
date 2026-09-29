/// The paid consultation methods the platform offers, from
/// `GET /api/consultation-methods?countryCode=BH`.
///
/// The catalogue is the platform's own pricing table (`code` is one of
/// `phone`, `whatsapp`, `video`, `office`). The booking endpoint validates the
/// submitted method against this same table, so the app must pick a real code
/// rather than inventing a consultation type.
class ConsultationMethod {
  final String id;
  final String code;
  final String nameAr;
  final String nameEn;
  final double price;
  final String currencyCode;
  final int durationMinutes;
  final String iconKey;
  final int sortOrder;

  ConsultationMethod({
    required this.id,
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.price,
    required this.currencyCode,
    required this.durationMinutes,
    required this.iconKey,
    required this.sortOrder,
  });

  String get name => nameAr.trim().isNotEmpty ? nameAr : nameEn;

  /// e.g. `35.000 BD` — the platform prices in 3-decimal Bahraini dinar.
  String get priceLabel => '${price.toStringAsFixed(3)} $currencyCode';

  /// Whether this method is the voice consultation the home action opens.
  bool get isVoice => code == 'phone' || code == 'whatsapp';

  /// Whether this method is the video consultation.
  bool get isVideo => code == 'video';

  /// Whether this method is an in-person office visit.
  bool get isOffice => code == 'office';

  factory ConsultationMethod.fromJson(Map<String, dynamic> json) => ConsultationMethod(
        id: json['id']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        nameAr: json['nameAr']?.toString() ?? '',
        nameEn: json['nameEn']?.toString() ?? '',
        price: double.tryParse('${json['price']}') ?? 0,
        currencyCode: json['currencyCode']?.toString() ?? 'BHD',
        durationMinutes: int.tryParse('${json['durationMinutes']}') ?? 30,
        iconKey: json['iconKey']?.toString() ?? '',
        sortOrder: int.tryParse('${json['sortOrder']}') ?? 0,
      );
}
