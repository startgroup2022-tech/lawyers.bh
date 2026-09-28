import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../services/auth_gate.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import 'messages_screen.dart';

/// The client's account hub: identity from `GET /auth/me`, the threads they
/// are part of, and logout. In [guest] mode it becomes a sign-in invitation
/// instead of an account view, and never touches private endpoints.
class ClientProfileScreen extends StatelessWidget {
  final bool guest;
  const ClientProfileScreen({super.key, this.guest = false});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = app.currentUser;

    if (guest || user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('حسابي')),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandSeal(size: 56),
                  const SizedBox(height: 16),
                  Text('أنت تتصفّح كزائر',
                      style: AppTextStyles.cairo(
                          size: 17, weight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Text(
                    'سجّل دخولك برقم هاتفك خلال ثوانٍ للوصول إلى العقود، متابعة القضايا، الرسائل، والنجدة القانونية العاجلة.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.tajawal(
                        size: 13, color: AppColors.ink2, height: 1.8),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: () => promptSignIn(context, feature: 'حسابك'),
                    child: const Text('تسجيل الدخول / إنشاء حساب'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [AppColors.brandDark, AppColors.brandBlue],
                ),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandLogo(height: 24, onDark: true),
                  const SizedBox(height: 14),
                  Text(user.displayName,
                      style: AppTextStyles.cairo(
                          size: 17,
                          weight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(user.phone,
                      style: AppTextStyles.tajawal(
                          size: 12.5, color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Column(
                children: [
                  _row(Icons.phone_outlined, 'الهاتف', user.phone),
                  const SizedBox(height: 12),
                  _row(Icons.email_outlined, 'البريد', user.email ?? '—'),
                  const SizedBox(height: 12),
                  _row(Icons.verified_user_outlined, 'الحالة',
                      user.isVerified == true ? 'موثّق' : 'بانتظار التوثيق'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _tile(
              context,
              Icons.forum_outlined,
              'الرسائل',
              'محادثاتك مع المحامين والدعم',
              () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MessagesScreen())),
            ),
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
                        style: AppTextStyles.cairo(
                            size: 15, weight: FontWeight.w800)),
                    content: Text('هل تريد تسجيل الخروج من حسابك؟',
                        style: AppTextStyles.tajawal(size: 12.5)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('إلغاء')),
                      FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: AppColors.red),
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
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) => Row(
        children: [
          Icon(icon, size: 16, color: AppColors.ink3),
          const SizedBox(width: 10),
          Text(label,
              style: AppTextStyles.tajawal(size: 11.5, color: AppColors.ink2)),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.tajawal(size: 12.5, color: AppColors.ink)),
          ),
        ],
      );

  Widget _tile(BuildContext context, IconData icon, String title,
          String subtitle, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.neutralBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 19, color: AppColors.brandRed),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.cairo(
                            size: 12.5, weight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: AppTextStyles.tajawal(
                            size: 10.5, color: AppColors.ink2)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, size: 19, color: AppColors.ink3),
            ],
          ),
        ),
      );
}
