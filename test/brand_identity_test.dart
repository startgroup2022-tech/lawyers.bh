import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawyers_bh_client/theme/app_theme.dart';

/// The app must present the official Lawyers.bh identity: the red the website
/// uses (B91D1C), one logo, and no remnants of the retired navy/gold palette.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('official brand identity', () {
    test('the primary red is the website colour', () {
      expect(AppColors.brandRed.toARGB32(), 0xFFB91D1C);
      expect(AppColors.crimson, AppColors.brandRed);
    });

    test('the lawyer workspace uses the same brand red, not navy/gold', () {
      expect(LawyerColors.base.toARGB32(), AppColors.brandRed.toARGB32());
      expect(LawyerColors.accent.toARGB32(), AppColors.brandRed.toARGB32());
    });

    test('the retired gold is gone from the palette', () {
      expect(LawyerColors.accent.toARGB32(), isNot(0xFFC59B27));
      expect(AppColors.neutralInk.toARGB32(), isNot(0xFF8A6D10));
    });

    test('the official logo assets are bundled', () async {
      for (final path in ['assets/brand/logo_color.png', 'assets/brand/logo_white.png']) {
        final data = await rootBundle.load(path);
        expect(data.lengthInBytes, greaterThan(0), reason: '$path must ship with the app');
      }
    });
  });
}
