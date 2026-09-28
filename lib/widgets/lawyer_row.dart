import 'package:flutter/material.dart';
import '../models/lawyer.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

class LawyerRow extends StatelessWidget {
  final Lawyer lawyer;
  final VoidCallback onTap;
  const LawyerRow({super.key, required this.lawyer, required this.onTap});

  BadgeTone get _availabilityTone {
    final label = lawyer.availabilityLabel ?? '';
    if (label.contains('اليوم')) return BadgeTone.green;
    if (label.contains('مجانية')) return BadgeTone.green;
    return BadgeTone.neutral;
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
                  Text('${lawyer.categoryName} · ${lawyer.location}',
                      style: AppTextStyles.tajawal(size: 11, color: AppColors.ink2)),
                  if (lawyer.availabilityLabel != null) ...[
                    const SizedBox(height: 6),
                    StatusBadge(label: lawyer.availabilityLabel!, tone: _availabilityTone),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                const Icon(Icons.chevron_left, color: AppColors.ink3, size: 20),
                const SizedBox(height: 4),
                Text('★ ${lawyer.rating}',
                    style: AppTextStyles.cairo(size: 12, weight: FontWeight.w700, color: AppColors.navy)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
