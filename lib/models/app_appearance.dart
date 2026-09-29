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

  /// A **bundled** image used when the admin has configured nothing, or when
  /// the configured image cannot be fetched. It ships inside the APK, so it is
  /// always available — including offline — and gives the app a visible global
  /// background out of the box.
  final String? assetPath;

  /// How strongly the image shows through, 0..1. 1 is fully opaque.
  final double imageOpacity;

  /// A light wash painted over the image to keep text legible, 0..1.
  final double overlayOpacity;

  /// Flat background colour behind (or instead of) the image.
  final Color? backgroundColor;

  const AppAppearance({
    this.backgroundUrl,
    this.assetPath,
    this.imageOpacity = 1.0,
    this.overlayOpacity = 0.0,
    this.backgroundColor,
  });

  /// What the app shows when the backend has nothing configured — the plain
  /// default background the app shipped with.
  static const AppAppearance defaults = AppAppearance();

  /// The image bundled with the app, painted at a low opacity behind the
  /// content. This is what a release build shows before (or instead of) an
  /// admin-configured image, so the global background is always visible.
  static const String bundledBackgroundAsset =
      'assets/images/app_background_default.png';

  /// The default background **with** the bundled image, used whenever the
  /// backend has no usable image of its own.
  static const AppAppearance demoBackground = AppAppearance(
    assetPath: bundledBackgroundAsset,
    imageOpacity: 0.35,
    overlayOpacity: 0.15,
  );

  /// The image to paint, preferring the admin's remote image and falling back
  /// to the bundled asset.
  String? get imageSource =>
      (backgroundUrl != null && backgroundUrl!.isNotEmpty)
          ? backgroundUrl
          : assetPath;

  /// True when [imageSource] is a bundled asset rather than a remote URL.
  bool get usesAssetImage =>
      (backgroundUrl == null || backgroundUrl!.isEmpty) &&
      assetPath != null &&
      assetPath!.isNotEmpty;

  bool get hasImage => imageSource != null && imageOpacity > 0;

  bool get hasBackground => hasImage || backgroundColor != null;

  /// This appearance with the bundled image filled in when nothing is
  /// configured. The global background must be visible even on a fresh install
  /// or an offline start, so the app always has a usable image to paint; the
  /// admin's colour and overlay are preserved when they exist.
  AppAppearance withVisibleBackground() {
    if (hasImage) return this;
    return AppAppearance(
      assetPath: bundledBackgroundAsset,
      imageOpacity: demoBackground.imageOpacity,
      overlayOpacity:
          overlayOpacity > 0 ? overlayOpacity : demoBackground.overlayOpacity,
      backgroundColor: backgroundColor,
    );
  }

  factory AppAppearance.fromJson(Map<String, dynamic> json) {
    final url = json['backgroundUrl']?.toString();
    final asset = json['assetPath']?.toString();
    return AppAppearance(
      backgroundUrl: (url != null && url.isNotEmpty) ? url : null,
      assetPath: (asset != null && asset.isNotEmpty) ? asset : null,
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
        'assetPath': assetPath,
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
      other.assetPath == assetPath &&
      other.imageOpacity == imageOpacity &&
      other.overlayOpacity == overlayOpacity &&
      other.backgroundColor == backgroundColor;

  @override
  int get hashCode =>
      Object.hash(backgroundUrl, assetPath, imageOpacity, overlayOpacity, backgroundColor);
}
