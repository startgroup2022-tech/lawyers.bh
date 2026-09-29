import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_appearance.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

/// Paints the admin-configured app background behind a screen's content.
///
/// The layer order, bottom to top, is:
///
///   1. the flat colour (the admin's colour, or [fallbackColor], or the default),
///   2. the background image at the configured (low) opacity,
///   3. an optional light wash so text stays legible,
///   4. purely decorative accents,
///   5. the screen's own content — the only interactive layer.
///
/// Layers 2–4 are wrapped in [IgnorePointer], so taps, scrolls, gestures and
/// form input always reach the content above; the background can never swallow
/// an interaction. When no image is configured the image resolves to the asset
/// bundled with the app, so a release build always shows a visible background;
/// a missing or failed image simply leaves the flat colour, and the content
/// renders normally either way.
class AppBackground extends StatelessWidget {
  final AppAppearance appearance;
  final Widget child;

  /// Shown when the admin has not set a flat colour. Lets each workspace keep
  /// the exact default it had before this feature (the client shell used the
  /// shared app colour; the lawyer workspace used its own canvas).
  final Color? fallbackColor;

  const AppBackground({
    super.key,
    required this.appearance,
    required this.child,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    final base = appearance.backgroundColor ?? fallbackColor ?? AppColors.bg;
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Flat colour — the ultimate fallback when there is no image.
        ColoredBox(color: base),
        // 2. Background image, low opacity, never interactive.
        if (appearance.hasImage)
          IgnorePointer(
            child: Opacity(
              opacity: appearance.imageOpacity.clamp(0.0, 1.0),
              child: _image(),
            ),
          ),
        // 3. Light overlay to keep the content readable over the image.
        if (appearance.overlayOpacity > 0)
          IgnorePointer(
            child: ColoredBox(
              color: Colors.white
                  .withValues(alpha: appearance.overlayOpacity.clamp(0.0, 1.0)),
            ),
          ),
        // 4. Decorative accents — visual only.
        const IgnorePointer(child: _BackgroundAccents()),
        // 5. The app's content: painted on top and the only hit-testable layer.
        child,
      ],
    );
  }

  Widget _image() {
    final source = appearance.imageSource!;
    if (appearance.usesAssetImage) {
      return Image.asset(
        source,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        // A missing bundled asset must leave the flat colour, not an error glyph.
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    }
    return Image.network(
      source,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      // A remote image that fails to load degrades to the flat colour (and the
      // decorative accents); the content is never affected.
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const SizedBox.shrink(),
    );
  }
}

/// The same background, reading the current appearance from [AppState].
///
/// This is the form screens use directly: it keeps the "which appearance" wiring
/// in one place instead of repeating `context.watch` at every call site.
class AppBackgroundScope extends StatelessWidget {
  final Widget child;
  final Color? fallbackColor;

  const AppBackgroundScope({super.key, required this.child, this.fallbackColor});

  @override
  Widget build(BuildContext context) {
    // Nullable lookup: screens are also exercised in tests without an
    // AppState, and a missing provider must simply mean the default background.
    // The default carries the bundled image, so the background is visible even
    // before (or without) a backend response.
    final appearance =
        Provider.of<AppState?>(context, listen: true)?.appAppearance ??
            AppAppearance.demoBackground;
    return AppBackground(
      appearance: appearance,
      fallbackColor: fallbackColor,
      child: child,
    );
  }
}

/// Purely decorative circles that give the background depth without ever
/// intercepting a touch (the caller wraps this in [IgnorePointer]).
class _BackgroundAccents extends StatelessWidget {
  const _BackgroundAccents();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: -70,
          right: -50,
          child: _blob(180, AppColors.brandRed.withValues(alpha: 0.05)),
        ),
        Positioned(
          bottom: 30,
          left: -60,
          child: _blob(220, AppColors.brandBlue.withValues(alpha: 0.045)),
        ),
      ],
    );
  }

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
