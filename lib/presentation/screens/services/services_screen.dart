import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lawyers_bh/core/router/app_router.dart';
import 'package:lawyers_bh/core/theme/app_theme.dart';
import 'package:lawyers_bh/presentation/common/widgets/common_widgets.dart';
import 'package:lawyers_bh/presentation/providers/locale_provider.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final services = [
      ServiceItem('استشارة قانونية', Icons.gavel, 'جلسة استشارة مع محامٍ مختص', 'ابتداءً من 50 د.ب', ConsultationType.video),
      ServiceItem('مراجعة عقد', Icons.description, 'مراجعة وتدقيق العقود القانونية', 'ابتداءً من 100 د.ب', ConsultationType.inPerson),
      ServiceItem('صياغة عقد', Icons.edit_document, 'صياغة عقود واتفاقيات مخصصة', 'ابتداءً من 200 د.ب', ConsultationType.inPerson),
      ServiceItem('تمثيل قضائي', Icons.account_balance, 'تمثيلك أمام المحاكم والنيابات', 'حسب القضية', ConsultationType.inPerson),
      ServiceItem('استشارة عن بعد', Icons.video_call, 'استشارة عبر الفيديو أو الصوت', 'ابتداءً من 30 د.ب', ConsultationType.video),
      ServiceItem('تأسيس شركة', Icons.business, 'إجراءات تأسيس الشركات والتراخيص', 'ابتداءً من 500 د.ب', ConsultationType.inPerson),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(l10n.secureContract),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final service = services[index];
          return _ServiceCard(service: service);
        },
      ),
    );
  }
}

class ServiceItem {
  final String title;
  final IconData icon;
  final String description;
  final String price;
  final ConsultationType defaultType;

  const ServiceItem(this.title, this.icon, this.description, this.price, this.defaultType);
}

class _ServiceCard extends StatelessWidget {
  final ServiceItem service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: () => context.go('${AppRoutes.lawyerDirectory}?service=${service.title}'),
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.goldBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(service.icon, color: const Color(0xFF8A6D10), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.title, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 4),
                  Text(service.description, style: AppTextStyles.bodySmall),
                  const SizedBox(height: 4),
                  Text(service.price, style: AppTextStyles.labelMedium.copyWith(color: AppColors.navy)),
                ],
              ),
            ),
            Icon(Icons.chevron_left, color: AppColors.ink3),
          ],
        ),
      ),
    );
  }
}