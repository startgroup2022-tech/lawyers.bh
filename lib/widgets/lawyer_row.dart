import 'package:flutter/material.dart';
import '../models/lawyer.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

class LawyerRow extends StatelessWidget {
  final Lawyer lawyer;
  final VoidCallback onTap;
  const LawyerRow({super.key, required this.lawyer, required this.onTap});

  /// A human label for the lawyer's subscription tier.
  String get _subscriptionLabel {
    switch (lawyer.subscriptionType) {
      case 'consultant':
        return 'استشاري';
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: AppColors.navyLight,
              child: Text(
                lawyer.initials,
                style: AppTextStyles.cairo(size: 14, weight: FontWeight.w800, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lawyer.name, style: AppTextStyles.cairo(size: 13, weight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(_subscriptionLabel,
                      style: AppTextStyles.tajawal(size: 11, color: AppColors.ink2)),
                  if (lawyer.isEmergencyReady) ...[
                    const SizedBox(height: 6),
                    const StatusBadge(label: 'نجدة عاجلة', tone: BadgeTone.green),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: AppColors.ink3, size: 20),
          ],
        ),
      ),
    );
  }
}
