import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawyers_bh/core/router/app_router.dart';
import 'package:lawyers_bh/core/theme/app_theme.dart';
import 'package:lawyers_bh/presentation/common/widgets/common_widgets.dart';
import 'package:lawyers_bh/presentation/providers/lawyers_provider.dart';
import 'package:lawyers_bh/presentation/providers/locale_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(lawyersProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(l10n.favorites),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
      ),
      body: state.favorites.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border,
              title: l10n.noFavorites,
              subtitle: 'اضغط على أيقونة القلب لحفظ المحامين المفضلين',
              action: AppButton(
                text: l10n.searchLawyers,
                onPressed: () => context.go(AppRoutes.search),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final lawyer = state.favorites[index];
                return _FavoriteLawyerItem(lawyer: lawyer);
              },
            ),
    );
  }
}

class _FavoriteLawyerItem extends StatelessWidget {
  final Lawyer lawyer;

  const _FavoriteLawyerItem({required this.lawyer});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: () => context.go('${AppRoutes.lawyerProfile}/${lawyer.id}'),
      borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        ),
        child: Row(
          children: [
            AppAvatar(name: lawyer.fullName, radius: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lawyer.fullName, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 2),
                  Text('${lawyer.specialty} · ${lawyer.location}', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(lawyer.formattedRating, style: AppTextStyles.ratingStyle),
                      const SizedBox(width: 12),
                      Text(lawyer.formattedFee, style: AppTextStyles.labelMedium.copyWith(color: AppColors.navy)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: AppColors.red),
              onPressed: () {},
            ),
            Icon(Icons.chevron_left, color: AppColors.ink3),
          ],
        ),
      ),
    );
  }
}