import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The professional workspace's section header: brand-red rule, red action.
///
/// Kept separate from the client's [SectionTitle] so the two rooms can carry
/// their own density and hierarchy within the one brand.
class ProSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  const ProSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 3,
            height: subtitle == null ? 16 : 30,
            decoration: BoxDecoration(
              color: LawyerColors.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.cairo(
                        size: 14.5, weight: FontWeight.w800, color: LawyerColors.base)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: AppTextStyles.tajawal(size: 11, color: LawyerColors.ink2)),
              ],
            ),
          ),
          if (actionLabel != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(actionLabel!,
                    style: AppTextStyles.cairo(
                        size: 11.5, weight: FontWeight.w700, color: LawyerColors.accent)),
              ),
            ),
        ],
      ),
    );
  }
}
