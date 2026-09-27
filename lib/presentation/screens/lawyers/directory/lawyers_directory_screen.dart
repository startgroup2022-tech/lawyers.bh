import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lawyers_bh/core/router/app_router.dart';
import 'package:lawyers_bh/core/theme/app_theme.dart';
import 'package:lawyers_bh/presentation/common/widgets/common_widgets.dart';
import 'package:lawyers_bh/presentation/providers/lawyers_provider.dart';
import 'package:lawyers_bh/presentation/providers/locale_provider.dart';
import 'package:lawyers_bh/domain/entities/lawyer.dart';

class LawyersDirectoryScreen extends ConsumerStatefulWidget {
  const LawyersDirectoryScreen({super.key});

  @override
  ConsumerState<LawyersDirectoryScreen> createState() => _LawyersDirectoryScreenState();
}

class _LawyersDirectoryScreenState extends ConsumerState<LawyersDirectoryScreen> {
  final _searchController = TextEditingController();
  String _selectedSpecialty = 'all';
  final List<String> _specialties = ['all', 'commercial', 'personalStatus', 'labor', 'criminal'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lawyersProvider.notifier).loadLawyers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.length >= 2) {
      ref.read(lawyersProvider.notifier).searchLawyers(query);
    } else if (query.isEmpty) {
      ref.read(lawyersProvider.notifier).loadLawyers();
    }
  }

  void _onSpecialtyChanged(String specialty) {
    setState(() => _selectedSpecialty = specialty);
    final filter = specialty == 'all' ? null : LawyerFilter(specialty: specialty);
    ref.read(lawyersProvider.notifier).loadLawyers(filter: filter);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(lawyersProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(l10n.lawyersDirectory),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: AppInputField(
              controller: _searchController,
              hint: l10n.search,
              prefixIcon: const Icon(Icons.search, color: AppColors.ink3),
              onChanged: _onSearchChanged,
            ),
          ),

          // Specialty chips
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _specialties.map((specialty) {
                  final isSelected = _selectedSpecialty == specialty;
                  final label = _getSpecialtyLabel(l10n, specialty);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AppChip(
                      label: label,
                      selected: isSelected,
                      onTap: () => _onSpecialtyChanged(specialty),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Results
          Expanded(
            child: state.isLoading && state.lawyers.isEmpty
                ? _buildShimmerList()
                : state.lawyers.isEmpty
                    ? EmptyState(
                        icon: Icons.person_search,
                        title: 'لا توجد نتائج',
                        subtitle: 'جرب تغيير معايير البحث',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.lawyers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final lawyer = state.lawyers[index];
                          return _LawyerListItem(lawyer: lawyer);
                        },
                      ),
          ),

          // Load more
          if (state.hasMore && !state.isLoadingMore)
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                text: 'تحميل المزيد',
                onPressed: () => ref.read(lawyersProvider.notifier).loadLawyers(),
              ),
            )
          else if (state.isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  String _getSpecialtyLabel(AppLocalizations l10n, String specialty) {
    switch (specialty) {
      case 'all':
        return l10n.all;
      case 'commercial':
        return l10n.commercial;
      case 'personalStatus':
        return l10n.personalStatus;
      case 'labor':
        return l10n.labor;
      case 'criminal':
        return l10n.criminal;
      default:
        return specialty;
    }
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => _LawyerListItemShimmer(),
    );
  }
}

class _LawyerListItem extends StatelessWidget {
  final Lawyer lawyer;

  const _LawyerListItem({required this.lawyer});

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
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            AppAvatar(name: lawyer.fullName, radius: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lawyer.fullName,
                          style: AppTextStyles.titleMedium,
                        ),
                      ),
                      Text(
                        lawyer.formattedRating,
                        style: AppTextStyles.ratingStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${lawyer.specialty} · ${lawyer.location}',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${lawyer.formattedExperience} · ${lawyer.formattedFee}/${l10n.bhd}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.ink2),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      AppBadge(
                        text: lawyer.badgeText,
                        type: _mapBadgeType(lawyer.badgeType),
                        fontSize: 8.5,
                      ),
                      ...lawyer.tags.take(2).map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            border: Border.all(color: AppColors.line),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tag,
                            style: AppTextStyles.caption.copyWith(fontSize: 9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_left, color: AppColors.ink3),
          ],
        ),
      ),
    );
  }

  BadgeType _mapBadgeType(LawyerBadgeType type) {
    switch (type) {
      case LawyerBadgeType.freeConsultation:
        return BadgeType.success;
      case LawyerBadgeType.acceptedAtCassation:
        return BadgeType.info;
      case LawyerBadgeType.availableToday:
        return BadgeType.success;
      case LawyerBadgeType.verified:
        return BadgeType.primary;
    }
  }
}

class _LawyerListItemShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 30, backgroundColor: AppColors.line),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: 120, color: AppColors.line),
                const SizedBox(height: 8),
                Container(height: 12, width: 160, color: AppColors.line),
                const SizedBox(height: 8),
                Container(height: 12, width: 100, color: AppColors.line),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(height: 20, width: 80, color: AppColors.line),
                    const SizedBox(width: 6),
                    Container(height: 20, width: 60, color: AppColors.line),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}