import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A compact KPI tile for the lawyer dashboard: value on top, label under.
class KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? accent;
  final VoidCallback? onTap;

  const KpiTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tone = accent ?? LawyerColors.accent;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: LawyerColors.surface,
          border: Border.all(color: LawyerColors.line),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 16, color: tone),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: AppTextStyles.cairo(
                    size: 20, weight: FontWeight.w800, color: LawyerColors.base)),
            const SizedBox(height: 2),
            Text(label,
                style: AppTextStyles.tajawal(size: 11, color: LawyerColors.ink2)),
          ],
        ),
      ),
    );
  }
}
