import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SectionTitle({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.cairo(size: 14.5, weight: FontWeight.w800, color: AppColors.navy)),
          if (actionLabel != null)
            InkWell(
              onTap: onAction,
              child: Text(actionLabel!,
                  style: AppTextStyles.cairo(size: 11, weight: FontWeight.w700, color: AppColors.crimson)),
            ),
        ],
      ),
    );
  }
}
