import 'package:flutter_test/flutter_test.dart';
import 'package:lawyers_bh/core/constants/app_constants.dart';
import 'package:lawyers_bh/core/theme/app_theme.dart';
import 'package:lawyers_bh/core/utils/app_logger.dart';

void main() {
  group('AppConstants Tests', () {
    test('App name should be correct', () {
      expect(AppConstants.appName, equals('محامون البحرين'));
      expect(AppConstants.appNameEn, equals('Lawyers.bh'));
    });

    test('Package names should be correct', () {
      expect(AppConstants.packageName, equals('com.lawyersbh.app'));
      expect(AppConstants.bundleId, equals('com.lawyersbh.app'));
    });

    test('Timeouts should be reasonable', () {
      expect(AppConstants.connectTimeout, equals(30000));
      expect(AppConstants.receiveTimeout, equals(30000));
      expect(AppConstants.sendTimeout, equals(30000));
    });

    test('Storage keys should be defined', () {
      expect(AppConstants.accessTokenKey, isNotEmpty);
      expect(AppConstants.refreshTokenKey, isNotEmpty);
      expect(AppConstants.userDataKey, isNotEmpty);
    });

    test('Border radius constants', () {
      expect(AppConstants.defaultBorderRadius, equals(14.0));
      expect(AppConstants.smallBorderRadius, equals(10.0));
      expect(AppConstants.largeBorderRadius, equals(22.0));
    });
  });

  group('AppColors Tests', () {
    test('Primary colors should match design', () {
      expect(AppColors.navy.value, equals(0xFF0F1E36));
      expect(AppColors.gold.value, equals(0xFFC59B27));
      expect(AppColors.crimson.value, equals(0xFF861F41));
    });

    test('Semantic colors should be correct', () {
      expect(AppColors.green.value, equals(0xFF1E7E34));
      expect(AppColors.red.value, equals(0xFFA62A2A));
      expect(AppColors.amber.value, equals(0xFFB7791F));
    });

    test('Background colors', () {
      expect(AppColors.bg.value, equals(0xFFF5F4F1));
      expect(AppColors.surface.value, equals(0xFFFFFFFF));
      expect(AppColors.line.value, equals(0xFFE7E3DA));
    });

    test('Text colors', () {
      expect(AppColors.ink.value, equals(0xFF171C26));
      expect(AppColors.ink2.value, equals(0xFF5B6472));
      expect(AppColors.ink3.value, equals(0xFF9AA1AC));
    });
  });

  group('AppTextStyles Tests', () {
    test('Display styles should use Cairo font', () {
      expect(AppTextStyles.displayLarge.fontFamily, equals('Cairo'));
      expect(AppTextStyles.displayMedium.fontFamily, equals('Cairo'));
      expect(AppTextStyles.displaySmall.fontFamily, equals('Cairo'));
    });

    test('Body styles should use Tajawal font', () {
      expect(AppTextStyles.bodyLarge.fontFamily, equals('Tajawal'));
      expect(AppTextStyles.bodyMedium.fontFamily, equals('Tajawal'));
      expect(AppTextStyles.bodySmall.fontFamily, equals('Tajawal'));
    });

    test('Font weights should be correct', () {
      expect(AppTextStyles.displayLarge.fontWeight, equals(FontWeight.w800));
      expect(AppTextStyles.headlineSmall.fontWeight, equals(FontWeight.w800));
      expect(AppTextStyles.bodyMedium.fontWeight, equals(FontWeight.w400));
      expect(AppTextStyles.labelLarge.fontWeight, equals(FontWeight.w700));
    });
  });
}