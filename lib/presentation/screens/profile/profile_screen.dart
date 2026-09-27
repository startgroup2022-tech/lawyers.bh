import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lawyers_bh/core/router/app_router.dart';
import 'package:lawyers_bh/core/theme/app_theme.dart';
import 'package:lawyers_bh/presentation/common/widgets/common_widgets.dart';
import 'package:lawyers_bh/presentation/providers/auth_provider.dart';
import 'package:lawyers_bh/presentation/providers/locale_provider.dart';
import 'package:lawyers_bh/presentation/providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(l10n.myProfile),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
      ),
      body: user == null
          ? Center(child: Text('يرجى تسجيل الدخول', style: AppTextStyles.bodyLarge))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.line),
                    borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
                  ),
                  child: Row(
                    children: [
                      AppAvatar(name: user.fullName, radius: 35, backgroundColor: AppColors.navyLight),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.fullName, style: AppTextStyles.headlineSmall),
                            const SizedBox(height: 4),
                            Text(user.email, style: AppTextStyles.bodySmall),
                            Text(user.phone, style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.go('${AppRoutes.settings}/edit-profile'),
                        icon: Icon(Icons.edit, color: AppColors.ink3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Menu items
                _ProfileSection(title: 'الحساب', children: [
                  _ProfileTile(
                    icon: Icons.person_outline,
                    title: l10n.editProfile,
                    onTap: () => context.go('${AppRoutes.settings}/edit-profile'),
                  ),
                  _ProfileTile(
                    icon: Icons.lock_outline,
                    title: l10n.changePassword,
                    onTap: () => context.go('${AppRoutes.settings}/change-password'),
                  ),
                  _ProfileTile(
                    icon: Icons.language,
                    title: l10n.language,
                    trailing: Text('العربية', style: AppTextStyles.bodySmall),
                    onTap: () => context.go('${AppRoutes.settings}/language'),
                  ),
                ]),
                const SizedBox(height: 16),

                _ProfileSection(title: 'التفضيلات', children: [
                  _ProfileTile(
                    icon: Icons.palette_outline,
                    title: l10n.theme,
                    trailing: Consumer(builder: (context, ref, _) {
                      final themeMode = ref.watch(themeProvider);
                      return Text(
                        themeMode == ThemeMode.dark ? 'داكن' : 'فاتح',
                        style: AppTextStyles.bodySmall,
                      );
                    }),
                    onTap: () => context.go('${AppRoutes.settings}/theme'),
                  ),
                  _ProfileTile(
                    icon: Icons.notifications_outlined,
                    title: l10n.notificationsSettings,
                    onTap: () => context.go('${AppRoutes.settings}/notifications'),
                  ),
                ]),
                const SizedBox(height: 16),

                _ProfileSection(title: 'الأمان', children: [
                  _ProfileTile(
                    icon: Icons.fingerprint,
                    title: l10n.biometricLogin,
                    trailing: Consumer(builder: (context, ref, _) {
                      return Switch(
                        value: false,
                        onChanged: (value) {},
                        activeColor: AppColors.navy,
                      );
                    }),
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 16),

                _ProfileSection(title: 'الدعم', children: [
                  _ProfileTile(
                    icon: Icons.help_outline,
                    title: l10n.helpSupport,
                    onTap: () => context.go(AppRoutes.help),
                  ),
                  _ProfileTile(
                    icon: Icons.info_outline,
                    title: l10n.aboutApp,
                    onTap: () => context.go(AppRoutes.about),
                  ),
                  _ProfileTile(
                    icon: Icons.description_outlined,
                    title: l10n.termsConditions,
                    onTap: () => context.go(AppRoutes.terms),
                  ),
                  _ProfileTile(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.privacyPolicy,
                    onTap: () => context.go(AppRoutes.privacy),
                  ),
                ]),
                const SizedBox(height: 24),

                // Logout button
                AppButton(
                  text: l10n.logout,
                  onPressed: () => _showLogoutDialog(context, ref, l10n),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, foregroundColor: AppColors.white),
                ),
                const SizedBox(height: 100),
              ],
            ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutConfirm),
        actions: [
          TextButton(onPressed: () => context.pop(), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              context.pop();
              ref.read(authProvider.notifier).logout();
              context.go(AppRoutes.login);
            },
            child: Text(l10n.yes, style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.labelMedium.copyWith(color: AppColors.ink3)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.ink2, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
            if (trailing != null) trailing!,
            if (trailing == null) Icon(Icons.chevron_left, color: AppColors.ink3),
          ],
        ),
      ),
    );
  }
}