import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lawyers_bh/core/router/app_router.dart';
import 'package:lawyers_bh/core/theme/app_theme.dart';
import 'package:lawyers_bh/presentation/common/widgets/common_widgets.dart';
import 'package:lawyers_bh/presentation/providers/lawyers_provider.dart';
import 'package:lawyers_bh/presentation/providers/locale_provider.dart';
import 'package:lawyers_bh/domain/entities/lawyer.dart';
import 'package:lawyers_bh/domain/entities/appointment.dart';
import 'package:url_launcher/url_launcher.dart';

class LawyerProfileScreen extends ConsumerStatefulWidget {
  final String lawyerId;

  const LawyerProfileScreen({super.key, required this.lawyerId});

  @override
  ConsumerState<LawyerProfileScreen> createState() => _LawyerProfileScreenState();
}

class _LawyerProfileScreenState extends ConsumerState<LawyerProfileScreen> {
  ConsultationType _selectedConsultationType = ConsultationType.video;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lawyersProvider.notifier).loadLawyerDetails(widget.lawyerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(lawyersProvider);
    final lawyer = state.selectedLawyer;

    if (lawyer == null && state.isLoading) {
      return _buildShimmer();
    }

    if (lawyer == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(backgroundColor: AppColors.navy, foregroundColor: AppColors.white),
        body: EmptyState(
          icon: Icons.person_off,
          title: 'لم يتم العثور على المحامي',
          action: AppButton(text: 'رجوع', onPressed: () => context.pop()),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // Hero section
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.navy,
            foregroundColor: AppColors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.navy, AppColors.navyLight],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppAvatar(name: lawyer.fullName, radius: 33, backgroundColor: AppColors.white, textColor: AppColors.navy),
                    const SizedBox(height: 12),
                    Text(
                      lawyer.fullName,
                      style: AppTextStyles.headlineMedium.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppColors.gold, size: 16),
                        const SizedBox(width: 4),
                        Text(lawyer.location, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
                        const SizedBox(width: 16),
                        const Icon(Icons.work_outline, color: AppColors.gold, size: 16),
                        const SizedBox(width: 4),
                        Text(lawyer.specialty, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats
                Row(
                  children: [
                    AppStat(value: lawyer.formattedRating, label: '${l10n.rating} (${lawyer.reviewsCount})', icon: const Icon(Icons.star, color: AppColors.gold, size: 20)),
                    const SizedBox(width: 8),
                    AppStat(value: lawyer.formattedExperience, label: l10n.experience, icon: const Icon(Icons.timeline, color: AppColors.navy, size: 20)),
                    const SizedBox(width: 8),
                    AppStat(value: lawyer.formattedFee, label: l10n.consultationFee),
                  ],
                ),
                const SizedBox(height: 24),

                // Badge
                if (lawyer.badgeText.isNotEmpty)
                  Center(
                    child: AppBadge(text: lawyer.badgeText, type: _mapBadgeType(lawyer.badgeType), fontSize: 11),
                  ),
                const SizedBox(height: 24),

                // Specialties tags
                AppSectionTitle(title: l10n.specialties),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: lawyer.tags.map((tag) => Chip(
                    label: Text(tag, style: AppTextStyles.bodySmall),
                    backgroundColor: AppColors.goldBg,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  )).toList(),
                ),
                const SizedBox(height: 24),

                // About
                AppSectionTitle(title: l10n.aboutLawyer),
                const SizedBox(height: 8),
                Text(lawyer.bio, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.ink2, height: 1.7)),
                const SizedBox(height: 24),

                // Consultation type
                AppSectionTitle(title: l10n.consultationType),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _ConsultationTypeChip(
                      type: ConsultationType.video,
                      label: l10n.videoCall,
                      icon: Icons.videocam,
                      isSelected: _selectedConsultationType == ConsultationType.video,
                      onTap: () => setState(() => _selectedConsultationType = ConsultationType.video),
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _ConsultationTypeChip(
                      type: ConsultationType.voice,
                      label: l10n.voiceCall,
                      icon: Icons.call,
                      isSelected: _selectedConsultationType == ConsultationType.voice,
                      onTap: () => setState(() => _selectedConsultationType = ConsultationType.voice),
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _ConsultationTypeChip(
                      type: ConsultationType.inPerson,
                      label: l10n.inPerson,
                      icon: Icons.meeting_room,
                      isSelected: _selectedConsultationType == ConsultationType.inPerson,
                      onTap: () => setState(() => _selectedConsultationType = ConsultationType.inPerson),
                    )),
                  ],
                ),
                const SizedBox(height: 24),

                // Contact buttons
                Row(
                  children: [
                    Expanded(child: _ContactButton(
                      icon: Icons.phone,
                      label: l10n.call,
                      color: AppColors.green,
                      onTap: () => _launchPhone('+973XXXXXXXX'),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _ContactButton(
                      icon: Icons.chat,
                      label: l10n.whatsapp,
                      color: const Color(0xFF25D366),
                      onTap: () => _launchWhatsApp('+973XXXXXXXX'),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _ContactButton(
                      icon: Icons.email,
                      label: l10n.message,
                      color: AppColors.navy,
                      onTap: () => _launchEmail('lawyer@example.com'),
                    )),
                  ],
                ),
                const SizedBox(height: 16),

                // Book consultation button
                AppButton(
                  text: l10n.bookConsultation,
                  onPressed: () => context.go('${AppRoutes.services}?lawyerId=${lawyer.id}&type=${_selectedConsultationType.name}'),
                  icon: const Icon(Icons.calendar_today, size: 20),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
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

  Widget _buildShimmer() {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.navy,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: AppColors.navy),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(child: Container(height: 80, color: AppColors.line)),
                    const SizedBox(width: 8),
                    Expanded(child: Container(height: 80, color: AppColors.line)),
                    const SizedBox(width: 8),
                    Expanded(child: Container(height: 80, color: AppColors.line)),
                  ],
                ),
                const SizedBox(height: 24),
                Container(height: 100, color: AppColors.line),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Container(height: 48, color: AppColors.line)),
                    const SizedBox(width: 8),
                    Expanded(child: Container(height: 48, color: AppColors.line)),
                    const SizedBox(width: 8),
                    Expanded(child: Container(height: 48, color: AppColors.line)),
                  ],
                ),
                const SizedBox(height: 24),
                Container(height: 56, color: AppColors.line),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchWhatsApp(String phone) async {
    final uri = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _ConsultationTypeChip extends StatelessWidget {
  final ConsultationType type;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ConsultationTypeChip({
    required this.type,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      child: AnimatedContainer(
        duration: AppConstants.shortAnimationDuration,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navy : AppColors.surface,
          border: Border.all(color: isSelected ? AppColors.navy : AppColors.line, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.gold : AppColors.ink2, size: 24),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: isSelected ? AppColors.gold : AppColors.ink2)),
          ],
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}