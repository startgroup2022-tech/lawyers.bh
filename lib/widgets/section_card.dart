import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A navigation destination in the home "main sections" grid.
///
/// [available] marks whether the app can actually open the section today. A
/// destination whose backend route does not exist on the mobile API is shown
/// disabled with a "قريبًا" tag and explains itself when tapped — it is never
/// wired to a fabricated screen or filled with placeholder data.
///
/// These are **categories/navigation**, not services: they belong to the
/// persistent structure of the app (looking up a lawyer, signing a contract,
/// tracking a case). Bookable offerings such as a voice or video consultation
/// are modelled separately by [ServiceItem].
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

/// A compact category tile: a tinted icon above a short label. Deliberately
/// low — the whole grid should read as a navigation strip, not a stack of
/// full-width cards.
class SectionCard extends StatelessWidget {
  final HomeSection section;
  const SectionCard({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: section.onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: section.available
                    ? section.tint.withValues(alpha: 0.12)
                    : AppColors.neutralBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                section.icon,
                size: 21,
                color: section.available ? section.tint : AppColors.ink3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              section.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.tajawal(
                size: 11,
                weight: FontWeight.w600,
                color: section.available ? AppColors.ink : AppColors.ink2,
                height: 1.3,
              ),
            ),
            if (!section.available) ...[
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.neutralBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('قريبًا',
                    style: AppTextStyles.tajawal(size: 9, color: AppColors.ink2)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The main-categories grid: four across on any phone-width screen (the
/// requested compact layout), widening on large screens and dropping to two
/// only when there is genuinely no room.
class SectionGrid extends StatelessWidget {
  final List<HomeSection> sections;
  const SectionGrid({super.key, required this.sections});

  int _columns(double width) {
    if (width >= 900) return 6;
    if (width >= 320) return 4;
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
          childAspectRatio: 0.86,
          children: sections.map((s) => SectionCard(section: s)).toList(),
        );
      },
    );
  }
}

/// One bookable offering — a voice or video consultation, or booking a time
/// with a lawyer.
///
/// These are **services/actions**, not categories, so they render as a compact
/// horizontal strip rather than tiles inside the category grid. [available] is
/// false until the platform exposes the matching mobile endpoint; tapping an
/// unavailable one explains the gap instead of opening a fabricated flow.
class ServiceItem {
  final String label;
  final IconData icon;
  final bool available;
  final VoidCallback onTap;

  const ServiceItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.available = false,
  });
}

/// A compact, horizontally scrollable row of service cards.
class ServicesStrip extends StatelessWidget {
  final List<ServiceItem> services;
  const ServicesStrip({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) => _serviceCard(services[i]),
      ),
    );
  }

  Widget _serviceCard(ServiceItem s) {
    return InkWell(
      onTap: s.onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        width: 104,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.neutralBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(s.icon, size: 19, color: AppColors.neutralInk),
            ),
            const SizedBox(height: 6),
            Text(s.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.tajawal(
                    size: 10.5,
                    weight: FontWeight.w600,
                    color: AppColors.ink,
                    height: 1.2)),
            if (!s.available) ...[
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.neutralBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('قريبًا',
                    style: AppTextStyles.tajawal(size: 9, color: AppColors.ink2)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
