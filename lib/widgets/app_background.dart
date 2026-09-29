import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_appearance.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

/// Paints the admin-configured app background behind a screen's content.
///
/// Three layers, bottom to top: the flat colour (or the default app colour), the
/// background image at the admin's opacity, then an optional light wash so text
/// stays legible. When no image is configured this is simply the default
/// background, so every screen keeps the look it had before the feature.
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
        ColoredBox(color: base),
        if (appearance.hasImage)
          Opacity(
            opacity: appearance.imageOpacity,
            child: Image.network(
              appearance.backgroundUrl!,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              // A failed or still-loading image must leave the plain background
              // visible, never an error glyph or a broken layout.
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const SizedBox.shrink(),
            ),
          ),
        if (appearance.overlayOpacity > 0)
          ColoredBox(
            color: Colors.white.withValues(alpha: appearance.overlayOpacity),
          ),
        child,
      ],
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
    // AppState, and a missing provider must simply mean "default background".
    final appearance =
        Provider.of<AppState?>(context, listen: true)?.appAppearance ??
            AppAppearance.defaults;
    return AppBackground(
      appearance: appearance,
      fallbackColor: fallbackColor,
      child: child,
    );
  }
}
