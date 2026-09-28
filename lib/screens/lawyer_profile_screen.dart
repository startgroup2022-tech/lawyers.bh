import 'package:flutter/material.dart';
import '../models/lawyer.dart';
import '../theme/app_theme.dart';

/// A lawyer's public profile, rendered from the directory record.
///
/// The platform API has no per-lawyer detail route, so this screen receives the
/// `Lawyer` already returned by `GET /api/mobile/lawyers` rather than fetching
/// a record that does not exist. Contact actions use the real phone/email the
/// directory publishes.
class LawyerProfileScreen extends StatelessWidget {
  final Lawyer lawyer;
  const LawyerProfileScreen({super.key, required this.lawyer});

  String get _subscriptionLabel {
    switch (lawyer.subscriptionType) {
      case 'consultant':
        return 'استشاري قانوني';
      case 'mediator':
        return 'وسيط';
      case 'arbitrator':
        return 'محكّم';
      case 'expert':
        return 'خبير';
      default:
        return 'محامٍ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.navy, AppColors.navyLight]),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_forward, size: 16, color: Color(0xFFCBD5E1)),
                          const SizedBox(width: 6),
                          Text('رجوع',
                              style: AppTextStyles.tajawal(size: 13, color: const Color(0xFFCBD5E1))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: CircleAvatar(
                        radius: 33,
                        backgroundColor: Colors.white,
                        child: Text(lawyer.initials,
                            style: AppTextStyles.cairo(
                                size: 20, weight: FontWeight.w800, color: AppColors.navy)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(lawyer.name,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.cairo(
                              size: 16, weight: FontWeight.w800, color: Colors.white)),
                    ),
                    if ((lawyer.nameEn ?? '').isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Center(
                        child: Text(lawyer.nameEn!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.tajawal(
                                size: 11.5, color: const Color(0xFFC9D3E4))),
                      ),
                    ],
                    const SizedBox(height: 3),
                    Center(
                      child: Text(_subscriptionLabel,
                          style: AppTextStyles.tajawal(
                              size: 11.5, color: const Color(0xFFC9D3E4))),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.line),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row(Icons.badge_outlined, 'الحالة', lawyer.status == 'approved' ? 'معتمد' : lawyer.status),
                      if (lawyer.isEmergencyReady)
                        _row(Icons.emergency_outlined, 'الخدمات', 'متاح للنجدة القانونية العاجلة'),
                      if ((lawyer.phone ?? '').isNotEmpty)
                        _row(Icons.call_outlined, 'الهاتف', lawyer.phone!),
                      if ((lawyer.email ?? '').isNotEmpty)
                        _row(Icons.mail_outline, 'البريد', lawyer.email!),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.neutralBg,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: AppColors.ink2),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'لطلب استشارة، تواصل مع المحامي مباشرة عبر الهاتف أو البريد.',
                          style: AppTextStyles.tajawal(
                              size: 12, color: AppColors.ink2, height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.navyLight),
          const SizedBox(width: 10),
          Text('$label: ',
              style: AppTextStyles.tajawal(
                  size: 12.5, weight: FontWeight.w600, color: AppColors.ink2)),
          Expanded(
            child: Text(value,
                style: AppTextStyles.tajawal(size: 12.5, color: AppColors.navy)),
          ),
        ],
      ),
    );
  }
}
