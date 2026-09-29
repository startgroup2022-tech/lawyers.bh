import 'dart:ui';

/// The app background configured by the admin panel.
///
/// Values arrive from `GET /api/mobile/appearance`; the image itself is stored
/// in the platform's blob storage and referenced by URL, never bundled with the
/// app. Opacity values are whole percentages on the wire and are held here as
/// 0..1 fractions for painting.
class AppAppearance {
  /// Blob URL of the background image, or null for the default background.
  final String? backgroundUrl;

  /// How strongly the image shows through, 0..1. 1 is fully opaque.
  final double imageOpacity;

  /// A light wash painted over the image to keep text legible, 0..1.
  final double overlayOpacity;

  /// Flat background colour behind (or instead of) the image.
  final Color? backgroundColor;

  const AppAppearance({
    this.backgroundUrl,
    this.imageOpacity = 1.0,
    this.overlayOpacity = 0.0,
    this.backgroundColor,
  });

  /// What the app shows when the backend has nothing configured — the plain
  /// default background the app shipped with.
  static const AppAppearance defaults = AppAppearance();

  bool get hasImage =>
      backgroundUrl != null && backgroundUrl!.isNotEmpty && imageOpacity > 0;

  bool get hasBackground => hasImage || backgroundColor != null;

  factory AppAppearance.fromJson(Map<String, dynamic> json) {
    final url = json['backgroundUrl']?.toString();
    return AppAppearance(
      backgroundUrl: (url != null && url.isNotEmpty) ? url : null,
      imageOpacity: _fraction(json['backgroundOpacity'], fallback: 1.0),
      overlayOpacity: _fraction(json['overlayOpacity'], fallback: 0.0),
      backgroundColor: _hexColor(json['backgroundColor']?.toString()),
    );
  }

  /// Serialised form kept in local storage so the last known background still
  /// shows when the app starts without a connection.
  ///
  /// Opacities are written back as whole percentages so the same [fromJson]
  /// parser can read them — storing the 0..1 fractions here would make a cached
  /// background render at 1/100th of the configured opacity.
  Map<String, dynamic> toJson() => {
        'backgroundUrl': backgroundUrl,
        'backgroundOpacity': (imageOpacity * 100).round(),
        'overlayOpacity': (overlayOpacity * 100).round(),
        'backgroundColor': backgroundColor == null
            ? null
            : '#${(backgroundColor!.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
      };

  static double _fraction(Object? percent, {required double fallback}) {
    final value = percent is num ? percent.toDouble() : double.tryParse('$percent');
    if (value == null || value.isNaN) return fallback;
    return (value / 100).clamp(0.0, 1.0);
  }

  static Color? _hexColor(String? value) {
    if (value == null) return null;
    final match = RegExp(r'^#([0-9A-Fa-f]{6})$').firstMatch(value.trim());
    if (match == null) return null;
    return Color(0xFF000000 | int.parse(match.group(1)!, radix: 16));
  }

  @override
  bool operator ==(Object other) =>
      other is AppAppearance &&
      other.backgroundUrl == backgroundUrl &&
      other.imageOpacity == imageOpacity &&
      other.overlayOpacity == overlayOpacity &&
      other.backgroundColor == backgroundColor;

  @override
  int get hashCode =>
      Object.hash(backgroundUrl, imageOpacity, overlayOpacity, backgroundColor);
}
