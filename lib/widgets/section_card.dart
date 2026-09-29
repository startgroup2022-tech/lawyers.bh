import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A single destination in the home "main sections" grid.
///
/// [available] marks whether the app can actually open the section today. A
/// section whose backend route does not exist on the mobile API is shown
/// disabled with a "قريبًا" tag and explains itself when tapped — it is never
/// wired to a fabricated screen or filled with placeholder data.
class HomeSection {
  final String label;
  final IconData icon;
  final Color tint;
  final bool available;
  final VoidCallback onTap;

  const HomeSection({
    required this.label,
    required this.icon,
    required this.tint,
    required this.onTap,
    this.available = true,
  });
}

/// One section tile: a tinted icon, an Arabic label, and a subtle chevron (or a
/// "قريبًا" badge when the section is not open yet).
class SectionCard extends StatelessWidget {
  final HomeSection section;
  const SectionCard({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: section.onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: section.available
                    ? section.tint.withValues(alpha: 0.12)
                    : AppColors.neutralBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                section.icon,
                size: 22,
                color: section.available ? section.tint : AppColors.ink3,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              section.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.tajawal(
                size: 11.5,
                weight: FontWeight.w600,
                color: section.available ? AppColors.ink : AppColors.ink2,
                height: 1.35,
              ),
            ),
            if (!section.available) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.neutralBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('قريبًا',
                    style: AppTextStyles.tajawal(size: 9.5, color: AppColors.ink2)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The main-sections grid, sized so it stays comfortable from a small phone to a
/// tablet: 2 columns under 380dp, 3 on a typical phone, 4 on a wide screen.
class SectionGrid extends StatelessWidget {
  final List<HomeSection> sections;
  const SectionGrid({super.key, required this.sections});

  int _columns(double width) {
    if (width >= 600) return 4;
    if (width >= 380) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columns(constraints.maxWidth);
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.92,
          children: sections.map((s) => SectionCard(section: s)).toList(),
        );
      },
    );
  }
}
