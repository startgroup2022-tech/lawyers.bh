import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawyers_bh/core/constants/app_constants.dart';
import 'package:lawyers_bh/core/theme/app_theme.dart';
import 'package:lawyers_bh/presentation/common/widgets/common_widgets.dart';
import 'package:lawyers_bh/presentation/providers/locale_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  String _appVersion = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(l10n.aboutApp),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                'assets/images/logo_full.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.gavel, size: 60, color: AppColors.navy),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: AppTextStyles.displayLarge,
            ),
            const SizedBox(height: 8),
            Text(
              AppConstants.appNameEn,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: 4),
            Text(
              'الإصدار $_appVersion ($_buildNumber)',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('عن المنصة', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 12),
                  Text(
                    'منصة محامين البحرين هي المنصة القانونية الأولى في مملكة البحرين، '
                    'توفر ربطاً مباشراً وآمناً بين العملاء وأفضل المحامين المرخصين في المملكة. '
                    'نحن نؤمن بأن الوصول للعدالة يجب أن يكون سهلاً وسريعاً ومضموناً.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.ink2, height: 1.7),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('المميزات', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 12),
                  _FeatureItem('تسجيل سريع بـ OTP', Icons.verified_user),
                  _FeatureItem('نجدة قانونية عاجلة', Icons.emergency),
                  _FeatureItem('عقود آمنة مع Escrow', Icons.security),
                  _FeatureItem('دفع عبر BenefitPay & Apple Pay', Icons.payment),
                  _FeatureItem('متابعة القضية لحظة بلحظة', Icons.timeline),
                  _FeatureItem('تقييمات ومراجعات موثوقة', Icons.star),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('معلومات قانونية', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 12),
                  _InfoRow('الجهة المشغلة', 'شركة محامون البحرين للتقنية القانونية'),
                  _InfoRow('الترخيص', 'مرخص من وزارة العدل والشؤون الإسلامية والأوقاف'),
                  _InfoRow('العنوان', 'مملكة البحرين - المنامة'),
                  _InfoRow('البريد الإلكتروني', 'legal@lawyers.bh'),
                  _InfoRow('الهاتف', '+973 17 XXX XXX'),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;
  final IconData icon;

  const _FeatureItem(this.text, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.ink3)),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}