import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawyers_bh/core/theme/app_theme.dart';
import 'package:lawyers_bh/presentation/common/widgets/common_widgets.dart';
import 'package:lawyers_bh/presentation/providers/locale_provider.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(l10n.strategicControlRoom),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
      ),
      body: CustomScrollView(
        slivers: [
          // KPIs
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.strategicControlRoom, style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 16),
                  _KPICard(label: l10n.transactionsThisMonth, value: '1,248', progress: 0.78, icon: Icons.receipt_long, color: AppColors.gold),
                  const SizedBox(height: 12),
                  _KPICard(label: l10n.avgResponseTime, value: '3.2 ساعة', progress: 0.55, icon: Icons.timer, color: AppColors.navy),
                  const SizedBox(height: 12),
                  _KPICard(label: l10n.customerSatisfaction, value: '4.8 / 5', progress: 0.96, icon: Icons.sentiment_very_satisfied, color: AppColors.green),
                  const SizedBox(height: 12),
                  _KPICard(label: l10n.activeCasesCount, value: '312', progress: 0.42, icon: Icons.gavel, color: AppColors.crimson),
                ],
              ),
            ),
          ),

          // Dispute resolution
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: AppSectionTitle(title: l10n.disputeResolution),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _DisputeCard(
                  title: l10n.documentDelay,
                  parties: l10n.lawyerClient,
                  level: l10n.medium,
                  levelColor: AppColors.amber,
                  onIntervene: () {},
                ),
                const SizedBox(height: 12),
                _DisputeCard(
                  title: l10n.feeDispute,
                  parties: l10n.lawyerClient,
                  level: l10n.high,
                  levelColor: AppColors.red,
                  onIntervene: () {},
                ),
              ]),
            ),
          ),

          // Management structure
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: AppSectionTitle(title: l10n.managementStructure),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _AdminRoleCard(
                  role: l10n.platformManager,
                  permissions: l10n.fullPermissions,
                  icon: Icons.admin_panel_settings,
                ),
                const SizedBox(height: 12),
                _AdminRoleCard(
                  role: l10n.disputeSupervisor,
                  permissions: l10n.manageDisputes,
                  icon: Icons.gavel,
                ),
                const SizedBox(height: 12),
                _AdminRoleCard(
                  role: l10n.platformAccountant,
                  permissions: l10n.escrowAccounts,
                  icon: Icons.account_balance,
                ),
                const SizedBox(height: 16),
                AppButton(text: l10n.addNewMember, onPressed: () {}, icon: const Icon(Icons.person_add)),
              ]),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}

class _KPICard extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final IconData icon;
  final Color color;

  const _KPICard({
    required this.label,
    required this.value,
    required this.progress,
    required this.icon,
    required this.color,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(value, style: AppTextStyles.statValue),
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 8),
          AppProgressBar(progress: progress, progressColor: color),
        ],
      ),
    );
  }
}

class _DisputeCard extends StatelessWidget {
  final String title;
  final String parties;
  final String level;
  final Color levelColor;
  final VoidCallback onIntervene;

  const _DisputeCard({
    required this.title,
    required this.parties,
    required this.level,
    required this.levelColor,
    required this.onIntervene,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(level, style: AppTextStyles.labelSmall.copyWith(color: levelColor)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('الأطراف: $parties', style: AppTextStyles.bodySmall),
          const SizedBox(height: 12),
          AppButton(
            text: 'تدخّل الآن',
            onPressed: onIntervene,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.crimson),
            icon: const Icon(Icons.shield, size: 18),
          ),
        ],
      ),
    );
  }
}

class _AdminRoleCard extends StatelessWidget {
  final String role;
  final String permissions;
  final IconData icon;

  const _AdminRoleCard({required this.role, required this.permissions, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.goldBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF8A6D10), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role, style: AppTextStyles.titleMedium),
                const SizedBox(height: 4),
                Text(permissions, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Icon(Icons.chevron_left, color: AppColors.ink3),
        ],
      ),
    );
  }
}