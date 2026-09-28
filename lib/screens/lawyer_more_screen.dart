import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/pro_badge.dart';
import '../widgets/pro_header.dart';
import '../widgets/pro_section_title.dart';
import 'availability_screen.dart';
import 'lawyer_documents_screen.dart';
import 'lawyer_profile_editor_screen.dart';
import 'messages_screen.dart';

/// The "more" hub: profile, schedule, documents, earnings and account.
class LawyerMoreScreen extends StatelessWidget {
  const LawyerMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = app.currentUser;

    return Scaffold(
      backgroundColor: LawyerColors.canvas,
      appBar: AppBar(
        backgroundColor: LawyerColors.base,
        title: const Text('المزيد'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (user != null) ProHeader(user: user, compact: true),
            const SizedBox(height: 18),
            const ProSectionTitle(title: 'إدارة المكتب'),
            _tile(context, Icons.badge_outlined, 'الملف المهني', 'بياناتك وأتعابك وحالة النشر',
                () => const LawyerProfileEditorScreen()),
            _tile(context, Icons.schedule_outlined, 'أوقات العمل', 'الجدول الأسبوعي والأيام المحجوبة',
                () => const AvailabilityScreen()),
            _tile(context, Icons.folder_copy_outlined, 'خزنة المستندات', 'مستندات القضايا والملفات',
                () => const LawyerDocumentsScreen()),
            _tile(context, Icons.forum_outlined, 'الرسائل', 'محادثات القضايا والعملاء',
                () => const MessagesScreen()),
            const SizedBox(height: 18),
            const ProSectionTitle(title: 'الحساب'),
            _accountCard(context),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                foregroundColor: AppColors.red,
                side: const BorderSide(color: Color(0xFFE7C7C7)),
              ),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('تسجيل الخروج',
                        style: AppTextStyles.cairo(size: 15, weight: FontWeight.w800)),
                    content: Text('هل تريد تسجيل الخروج من حسابك؟',
                        style: AppTextStyles.tajawal(size: 12.5)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: AppColors.red),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('خروج'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await context.read<AppState>().logout();
                }
              },
              icon: const Icon(Icons.logout, size: 17),
              label: const Text('تسجيل الخروج'),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: LawyerColors.surface,
            border: Border.all(color: LawyerColors.line),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: LawyerColors.accentSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 19, color: LawyerColors.accent),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.cairo(size: 12.5, weight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: AppTextStyles.tajawal(size: 10.5, color: LawyerColors.ink2)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, size: 19, color: LawyerColors.ink3),
            ],
          ),
        ),
      );

  Widget _accountCard(BuildContext context) {
    final user = context.read<AppState>().currentUser;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LawyerColors.surface,
        border: Border.all(color: LawyerColors.line),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 16, color: LawyerColors.ink3),
              const SizedBox(width: 10),
              Text('الهاتف', style: AppTextStyles.tajawal(size: 11.5, color: LawyerColors.ink2)),
              const Spacer(),
              Text(user?.phone ?? '—',
                  style: AppTextStyles.tajawal(size: 12.5, color: LawyerColors.ink)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.verified_user_outlined, size: 16, color: LawyerColors.ink3),
              const SizedBox(width: 10),
              Text('الأدوار', style: AppTextStyles.tajawal(size: 11.5, color: LawyerColors.ink2)),
              const Spacer(),
              Wrap(
                spacing: 6,
                children: (user?.roles.isEmpty == true ? [user?.role ?? ''] : user!.roles)
                    .map((r) => ProBadge(label: _roleLabel(r), tone: LawyerColors.base2))
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _roleLabel(String slug) {
    switch (slug) {
      case 'lawyer':
        return 'محامٍ';
      case 'law_firm_owner':
        return 'مالك مكتب';
      case 'law_firm_manager':
        return 'مدير مكتب';
      case 'lawyer_staff':
        return 'موظف قانوني';
      case 'client':
        return 'عميل';
      case 'admin':
        return 'مشرف';
      default:
        return slug;
    }
  }
}
