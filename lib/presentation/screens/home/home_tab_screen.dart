import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lawyers_bh/core/router/app_router.dart';
import 'package:lawyers_bh/core/theme/app_theme.dart';
import 'package:lawyers_bh/presentation/common/widgets/common_widgets.dart';
import 'package:lawyers_bh/presentation/providers/auth_provider.dart';
import 'package:lawyers_bh/presentation/providers/lawyers_provider.dart';
import 'package:lawyers_bh/presentation/providers/locale_provider.dart';

class HomeTabScreen extends ConsumerStatefulWidget {
  const HomeTabScreen({super.key});

  @override
  ConsumerState<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends ConsumerState<HomeTabScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lawyersProvider.notifier).loadRecommendedLawyers(limit: 4);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final lawyersState = ref.watch(lawyersProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // App bar with user greeting and SOS
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.navy,
            elevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: 100,
            flexibleSpace: Container(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: AppColors.white,
                    child: Text(
                      user?.initials ?? '؟',
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.navy),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'مرحباً، ${user?.fullName.split(' ').first ?? 'ضيف'}',
                          style: AppTextStyles.titleMedium.copyWith(color: AppColors.white),
                        ),
                        Text(
                          l10n.welcomeDesc,
                          style: AppTextStyles.caption.copyWith(color: AppColors.white.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
                  // SOS Button
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.crimson,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.shield, color: AppColors.white, size: 20),
                      tooltip: 'نجدة قانونية',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Hero Section - Quick Registration & Legal Aid
                _buildHeroSection(l10n),
                const SizedBox(height: 24),

                // Browse by Specialty
                _buildSpecialtySection(l10n),
                const SizedBox(height: 24),

                // Recommended Lawyers
                _buildRecommendedLawyers(l10n, lawyersState),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.navyLight, AppColors.crimson],
        ),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.urgentLegalAid,
            style: AppTextStyles.headlineLarge.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.urgentLegalAidDesc,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white.withOpacity(0.9)),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: l10n.searchLawyers,
                  onPressed: () => context.go(AppRoutes.search),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.navy,
                  ),
                  icon: const Icon(Icons.search, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppOutlinedButton(
                  text: 'نجدة قانونية',
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.white, width: 1.5),
                    foregroundColor: AppColors.white,
                  ),
                  icon: const Icon(Icons.emergency, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtySection(AppLocalizations l10n) {
    final specialties = [
      ('تجاري', Icons.business_outlined),
      ('أحوال شخصية', Icons.people_outline),
      ('عمالي', Icons.work_outline),
      ('جنائي', Icons.gavel_outlined),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionTitle(
          title: l10n.browseBySpecialty,
          actionText: l10n.viewAll,
          onAction: () => context.go(AppRoutes.search),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: specialties.length,
          itemBuilder: (context, index) {
            final (label, icon) = specialties[index];
            return InkWell(
              onTap: () => context.go(AppRoutes.search),
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.goldBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: const Color(0xFF8A6D10), size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecommendedLawyers(AppLocalizations l10n, LawyersState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionTitle(
          title: l10n.recommendedLawyers,
          actionText: l10n.viewAll,
          onAction: () => context.go(AppRoutes.search),
        ),
        const SizedBox(height: 12),
        if (state.isLoading)
          _buildLawyerShimmer()
        else if (state.recommendedLawyers.isEmpty)
          _buildEmptyLawyers(l10n)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.recommendedLawyers.length.clamp(0, 2),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final lawyer = state.recommendedLawyers[index];
              return _LawyerCard(lawyer: lawyer);
            },
          ),
      ],
    );
  }

  Widget _buildLawyerShimmer() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _LawyerCardShimmer(),
    );
  }

  Widget _buildEmptyLawyers(AppLocalizations l10n) {
    return EmptyState(
      icon: Icons.person_search,
      title: 'لا يوجد محامون حالياً',
      subtitle: 'سيعرض هنا المحامون الموصى بهم عند توفرهم',
    );
  }
}

class _LawyerCard extends StatelessWidget {
  final Lawyer lawyer;

  const _LawyerCard({required this.lawyer});

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
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
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
                  Text(
                    '${lawyer.specialty} · ${lawyer.location}',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  AppBadge(text: lawyer.badgeText, type: _mapBadgeType(lawyer.badgeType)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.chevron_left, color: AppColors.ink3),
                const SizedBox(height: 4),
                Text(
                  lawyer.formattedRating,
                  style: AppTextStyles.ratingStyle,
                ),
              ],
            ),
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

class _LawyerCardShimmer extends StatelessWidget {
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
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.line,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: 120, color: AppColors.line),
                const SizedBox(height: 8),
                Container(height: 12, width: 160, color: AppColors.line),
                const SizedBox(height: 12),
                Container(height: 20, width: 80, color: AppColors.line),
              ],
            ),
          ),
        ],
      ),
    );
  }
}