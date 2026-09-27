import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lawyers_bh/core/router/app_router.dart';
import 'package:lawyers_bh/core/theme/app_theme.dart';
import 'package:lawyers_bh/presentation/common/widgets/common_widgets.dart';
import 'package:lawyers_bh/presentation/providers/locale_provider.dart';

class LawyerDashboardScreen extends ConsumerWidget {
  const LawyerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(l10n.dashboard),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Stats
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(child: AppStat(value: '7', label: l10n.activeCases, icon: const Icon(Icons.folder, color: AppColors.navy))),
                  const SizedBox(width: 8),
                  Expanded(child: AppStat(value: '3', label: l10n.pendingOffers, icon: const Icon(Icons.pending_actions, color: AppColors.amber))),
                  const SizedBox(width: 8),
                  Expanded(child: AppStat(value: '1,860', label: l10n.monthlyFees, icon: const Icon(Icons.attach_money, color: AppColors.green))),
                ],
              ),
            ),
          ),

          // New negotiation requests
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: AppSectionTitle(title: l10n.newNegotiationRequests),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _NegotiationRequestCard(
                  client: 'شركة الخليج للمقاولات',
                  caseType: 'نزاع عقد تجاري',
                  time: 'قبل 10 دقائق',
                  onAccept: () {},
                  onReject: () {},
                ),
                const SizedBox(height: 12),
                _NegotiationRequestCard(
                  client: 'سارة أحمد',
                  caseType: 'قضية أحوال شخصية',
                  time: 'قبل ساعة',
                  onAccept: () {},
                  onReject: () {},
                ),
              ]),
            ),
          ),

          // Quick fee calculator
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.quickFeeCalculator, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 12),
                    AppInputField(
                      label: l10n.hours,
                      hint: 'مثال: 4',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: l10n.calculateSuggestedFees,
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.navy),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Navigation shortcuts
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: AppSectionTitle(title: 'إجراءات سريعة'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              delegate: SliverChildListDelegate([
                _QuickActionCard(icon: Icons.folder, label: l10n.contractsFiles, onTap: () => context.go(AppRoutes.lawyerDashboard + '/contracts')),
                _QuickActionCard(icon: Icons.notifications, label: l10n.notifications, onTap: () {}),
                _QuickActionCard(icon: Icons.calendar_today, label: 'مواعيدي', onTap: () {}),
                _QuickActionCard(icon: Icons.analytics, label: 'إحصائياتي', onTap: () {}),
              ]),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}

class _NegotiationRequestCard extends StatelessWidget {
  final String client;
  final String caseType;
  final String time;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _NegotiationRequestCard({
    required this.client,
    required this.caseType,
    required this.time,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(client, style: AppTextStyles.titleMedium),
          const SizedBox(height: 4),
          Text('$caseType · $time', style: AppTextStyles.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: AppButton(text: 'قبول', onPressed: onAccept, style: ElevatedButton.styleFrom(backgroundColor: AppColors.green))),
              const SizedBox(width: 8),
              Expanded(child: AppOutlinedButton(text: 'رفض', onPressed: onReject, style: OutlinedButton.styleFrom(foregroundColor: AppColors.red))),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.navy),
            const SizedBox(height: 12),
            Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}