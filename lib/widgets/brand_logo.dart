import 'package:flutter/material.dart';

/// The official Lawyers.bh mark.
///
/// The asset is the same artwork the website serves, so the app and the site
/// share one logo. [onDark] swaps to the white rendering (dark strokes become
/// white, the brand red is preserved) for use over the red/navy surfaces.
class BrandLogo extends StatelessWidget {
  final double height;
  final bool onDark;

  const BrandLogo({super.key, this.height = 34, this.onDark = false});

  /// The wordmark's own aspect ratio (900x222). Deriving the width from
  /// [height] means the box is known before the image decodes, so a
  /// fixed-size parent is not measured against the raw asset's fallback box.
  static const double _aspectRatio = 900 / 222;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: height * _aspectRatio,
      child: Image.asset(
        onDark ? 'assets/brand/logo_white.png' : 'assets/brand/logo_color.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        semanticLabel: 'محامون البحرين',
      ),
    );
  }
}

/// A small circular brand seal for compact spots (app bars, list headers).
///
/// The seal always paints the colour mark on a white disc, so it stays legible
/// against either a red or a light app bar.
class BrandSeal extends StatelessWidget {
  final double size;

  const BrandSeal({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(size * 0.16),
        child: Image.asset(
          'assets/images/logo_bh.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          semanticLabel: 'محامون البحرين',
        ),
      ),
    );
  }
}
