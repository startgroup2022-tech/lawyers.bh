import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';

const Map<String, IconData> categoryIcons = {
  'briefcase': Icons.work_outline,
  'users': Icons.groups_outlined,
  'folder': Icons.folder_open_outlined,
  'shieldalert': Icons.gpp_maybe_outlined,
};

class CategoryTile extends StatelessWidget {
  final LegalCategory category;
  final VoidCallback onTap;
  const CategoryTile({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: AppColors.neutralBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(categoryIcons[category.iconKey] ?? Icons.work_outline,
                  size: 18, color: AppColors.neutralInk),
            ),
            const SizedBox(height: 6),
            Text(
              category.nameAr,
              textAlign: TextAlign.center,
              style: AppTextStyles.tajawal(size: 10.5, weight: FontWeight.w600, color: AppColors.ink2),
            ),
          ],
        ),
      ),
    );
  }
}
