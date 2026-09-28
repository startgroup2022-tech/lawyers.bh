import 'package:flutter/material.dart';
import '../models/lawyer_profile.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import 'brand_logo.dart';

/// The lawyer workspace masthead.
///
/// This is the app's "professional identity" moment: the official brand red, the
/// Lawyers.bh mark, the lawyer's name set in the brand display face, and their
/// verification standing stated plainly. It reads as a practice letterhead
/// rather than a consumer profile card, without introducing a second palette.
class ProHeader extends StatelessWidget {
  final AppUser user;
  final LawyerProfile? profile;
  final VoidCallback? onTap;
  final bool compact;

  const ProHeader({
    super.key,
    required this.user,
    this.profile,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final name = profile?.professionalName.isNotEmpty == true
        ? profile!.professionalName
        : user.displayName;
    final verified = profile?.isVerified ?? false;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Container(
        padding: EdgeInsets.all(compact ? 16 : 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [LawyerColors.base, LawyerColors.base2],
          ),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: [
            BoxShadow(
              color: LawyerColors.base.withValues(alpha: 0.25),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BrandSeal(size: 16),
                      const SizedBox(width: 5),
                      Text('المكتب المهني',
                          style: AppTextStyles.cairo(
                              size: 9.5, weight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
                const Spacer(),
                if (verified)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, size: 14, color: LawyerColors.emerald),
                      const SizedBox(width: 4),
                      Text('موثّق',
                          style: AppTextStyles.cairo(
                              size: 10, weight: FontWeight.w700, color: LawyerColors.emerald)),
                    ],
                  )
                else
                  Text('قيد التوثيق',
                      style: AppTextStyles.cairo(
                          size: 10, weight: FontWeight.w700, color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials(name),
                    style: AppTextStyles.cairo(
                        size: 18, weight: FontWeight.w800, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: AppTextStyles.cairo(
                              size: 17, weight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 3),
                      Text(
                        _subtitle(),
                        style: AppTextStyles.tajawal(
                            size: 11.5, color: const Color(0xFFB9C6DA)),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(Icons.chevron_left, color: Color(0xFF7C8DA6), size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.10)),
            const SizedBox(height: 12),
            Row(
              children: [
                _Metric(
                  icon: Icons.star_rounded,
                  value: (profile?.rating ?? 0).toStringAsFixed(1),
                  label: 'التقييم',
                ),
                _divider(),
                _Metric(
                  icon: Icons.workspace_premium_outlined,
                  value: '${profile?.experienceYears ?? 0}',
                  label: 'سنوات خبرة',
                ),
                _divider(),
                _Metric(
                  icon: Icons.gavel_outlined,
                  value: '${profile?.completedCasesCount ?? 0}',
                  label: 'قضية منجزة',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _subtitle() {
    final p = profile;
    if (p == null) return 'جاري تحميل الملف المهني…';
    final bits = <String>[];
    if (p.specializations.isNotEmpty) bits.add(p.specializations.first.nameAr);
    if ((p.city ?? '').isNotEmpty) bits.add(p.city!);
    if (p.services.isNotEmpty) bits.add('${p.services.length} خدمة');
    return bits.isEmpty ? 'أكمل ملفك المهني' : bits.join(' · ');
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join();
  }

  Widget _divider() => Container(
        width: 1,
        height: 26,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        color: Colors.white.withValues(alpha: 0.12),
      );
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Metric({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: AppTextStyles.cairo(
                      size: 13, weight: FontWeight.w800, color: Colors.white)),
              Text(label,
                  style: AppTextStyles.tajawal(size: 9.5, color: const Color(0xFF9FB0C7))),
            ],
          ),
        ],
      ),
    );
  }
}
